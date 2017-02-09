require "erb"

module Jekyll
  class Commands::NewSite < Command
    class << self
      def init_with_program(prog)
        prog.command(:"new-site") do |c|
          c.syntax      "new-site PATH"
          c.description "Creates a custom Jekyll site scaffold in PATH"

          c.option "classic", "--classic", "Classic Jekyll scaffolding"
          c.option "theme", "--theme GEM-NAME", "Scaffold with a custom gem-based theme"
          c.option "force", "--force", "Force creation even if PATH already exists"
          c.option "verbose", "--verbose", "Output messages while creating"

          c.action do |args, options|
            process(args, options)
          end
        end
      end

      def process(args, options = {})
        raise ArgumentError, "You must specify a path." if args.empty?

        site_path = File.expand_path(args.join(" "), Dir.pwd)
        FileUtils.mkdir_p site_path
        if existing_source_location?(site_path, options)
          Jekyll.logger.abort_with "Conflict:", "#{site_path} exists and is not empty."
        end

        initialize_git site_path if git_installed?
        create_variables_from(args, options)

        create_site site_path, options
      end

      #
      # private methods
      #

      private

      # join the arguments given, with a whitespace; replace backslashes, if any
      # with a forward slash; split the string into an array again and select the
      # last entry.
      # Further split the entry along a single whitespace, and map to a new array
      # after capitalizing the split-entries. Join them again with a whitespace
      # to form the final title string.
      def extract_title_from(args)
        a = args.join(" ").tr("\\", "/").split("/").last
        a.split.map(&:capitalize).join(" ")
      end

      def create_variables_from(args, options)
        @verbose = options["verbose"]

        @theme = options["theme"] ? options["theme"] : "minima"
        @name  = user_name
        @email = user_email

        # extract capitalized blog title from the argument(s) when a 'path'
        # to the new site has been provided.
        #   e.g.  jekyll new work/blogs/exploring ruby would install a blog
        #   titled 'Exploring Ruby' at path ~/work/blogs/exploring ruby
        @title   = extract_title_from(args)
      end

      def create_site(path, options)
        add_foundation_files path
        create_scaffold_at path

        if options["classic"]
          bundle_unless_theme_installed path
          extract_templates_and_config path
        elsif options["theme"]
          bundle_unless_theme_installed path
          extract_theme_config path
        end

        success_message path, options
      end

      def add_foundation_files(path)
        print_header "Creating:", "Foundation files"
        process_template_for "Gemfile", site_template, path
        process_template_for "_config.yml", site_template, path
        print ""
      end

      def create_scaffold_at(path)
        print_header "Creating:", "Scaffold files"
        FileUtils.mkdir_p(File.expand_path("_posts", path))

        pages = %w(index.html about.md)
        pages << ".gitignore"
        pages.each do |page|
          write_file(page, erb_render("#{page}.erb", site_template), path)
        end
        write_file(welcome_post, erb_render(scaffold_path, site_template), path)
        print ""
      end

      def extract_templates_and_config(path)
        print_header(
          "Extracting:",
          "Templates and _config.yml from #{@theme.cyan} if available..",
          "="
        )
        package = \
          %w(
            _layouts _includes _sass _data assets _config.yml
          )
        Dir.chdir(path) do
          Commands::ExtractTheme.process(package, extraction_opts)
        end
      end

      def extract_theme_config(path)
        print_header(
          "Extracting:",
          "_config.yml from theme-gem if available..",
          "="
        )
        Dir.chdir(path) do
          Commands::ExtractTheme.process(%w(_config.yml), extraction_opts)
        end
      end

      def git_installed?
        process, _output = Utils::Exec.run("git", "--version")
        process.success?
      end

      def extraction_opts
        @verbose ? "--force --lax --verbose" : "--force --lax --quiet"
      end

      def success_message(path, options)
        print_info ""
        if options["classic"]
          print_info "A classic-style jekyll site #{@title.cyan} installed " \
                     " in #{path.cyan}."

        elsif options["theme"]
          print_info "New #{@theme.cyan} themed jekyll site #{@title.cyan} " \
                     "installed in #{path.cyan}."

        else
          print_info "New jekyll site #{@title.cyan} installed in #{path.cyan}."
        end
      end

      def bundle_unless_theme_installed(path)
        print_info "Checking:", "Local theme installation..."
        Gem::Specification.find_by_name(@theme)
        theme_installed_msg
        print_info ""
      rescue Gem::LoadError
        Jekyll.logger.error "Jekyll+:", "Theme #{@theme.inspect} could not be found."
        bundle_install path
        print_info ""
      end

      def bundle_install(path)
        print_info "Jekyll+:", "Running bundle install in #{path.cyan}..."
        Dir.chdir(path) do
          process, output = Utils::Exec.run("bundle", "install")
          report = output.to_s.each_line.map(&:strip)
          print_info "Bundler:", report.first
          report[1..-1].each { |line| print_info "", line }
          raise SystemExit unless process.success?
        end
      end

      def theme_installed_msg
        print_info "", "#{@theme.inspect} local installation found." \
                       " Bundle install skipped".green
      end

      def process_template_for(file, source, destination)
        print "Creating:", File.join(destination, file)
        File.open(File.join(destination, file), "w") do |f|
          f.write(
            erb_render("#{file}.erb", source)
          )
        end
      end

      def write_file(filename, contents, path)
        full_path = File.expand_path(filename, path)
        print "Creating:", full_path
        File.write(full_path, contents)
      end

      def erb_render(filename, source)
        ERB.new(File.read(File.expand_path(filename, source))).result(binding)
      end

      def welcome_post
        "_posts/#{Time.now.strftime("%Y-%m-%d")}-welcome-to-jekyll.md"
      end

      def existing_source_location?(path, options)
        !options["force"] && !Dir["#{path}/**/*"].empty?
      end

      def site_template
        File.expand_path("../site_template", File.dirname(__FILE__))
      end

      def scaffold_path
        "_posts/0000-00-00-welcome-to-jekyll.md.erb"
      end

      def initialize_git(path)
        print "Initialising:", File.join(path, ".git")
        Dir.chdir(path) { `git init` }
      end

      def user_name
        name ||= `git config user.name`.chomp
        name.empty? ? "Github User" : name
      end

      def user_email
        email ||= `git config user.email`.chomp
        email.empty? ? "your-email@domain.com" : email
      end

      def print_info(topic, message = "")
        Jekyll.logger.info topic, message
      end

      # only with --verbose switch
      def print(topic, message = "")
        if @verbose
          Jekyll.logger.info topic, message.to_s.cyan
        end
      end

      def print_header(topic, message, style = "-")
        print_info topic, message
        print "", style * message.length
      end
    end
  end
end
