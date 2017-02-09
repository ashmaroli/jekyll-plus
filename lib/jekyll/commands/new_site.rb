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
          c.option "skip-bundle", "--skip-bundle", "Skip 'bundle install'"
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

        if options["theme"]
          add_supporting_files site_path
          bundle_install site_path
        end

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
        create_default_site_at path
        add_supporting_files path
        after_install path, options
      end

      def create_default_site_at(path)

        FileUtils.mkdir_p(File.expand_path("_posts", path))
        source = site_template

        pages = %w(index.html about.md)
        pages << ".gitignore"
        pages.each { |page| write_file(page, erb_render("#{page}.erb", source), path) }
        write_file(welcome_post, erb_render(scaffold_path, source), path)
      end

      def add_supporting_files(path)
        source = site_template
        process_template_for "Gemfile", source, path
        process_template_for "_config.yml", source, path
        print ""
      end

      def git_installed?
        process, _output = Utils::Exec.run("git", "--version")
        process.success?
      end

      # After a new blog has been installed, print a success notification and then
      # automatically execute bundle install from within the new blog dir unless
      # the user opts to generate a classic Jekyll blog or skip 'bundle install'
      # using the `--skip-bundle` switch
      def after_install(path, options)
        extract_theme_config path if options["theme"]

        if options["classic"]
          print "Creating:", "Classic directories and files"
          scaffold_directories = %w(
            _layouts _includes _sass _data assets
          )
          Dir.chdir(path) do
            Commands::ExtractTheme.process(scaffold_directories, "--lax")
          end
          print_info "New classic-style jekyll site installed in #{path.cyan}."
        else
          print_info "New jekyll site #{@title.cyan} installed in #{path.cyan}."
        end

        print_info "Bundle install skipped." if options["skip-bundle"]
        unless options["classic"] || options["skip-bundle"] || options["theme"]
          bundle_install path
        end
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

      def extract_theme_config(path)
        Dir.chdir(path) do
          Commands::ExtractTheme.process(
            %w(_config.yml), "--force, --lax"
          )
        end
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
    end
  end
end
