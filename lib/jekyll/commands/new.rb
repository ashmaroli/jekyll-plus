require "erb"

module Jekyll
  class Commands::New < Command
    class << self
      def init_with_program(prog)
      end

      def process(args, options = {})
        @verbose = options["verbose"]

        raise ArgumentError, "You must specify a path." if args.empty?

        # extract capitalized blog title from the argument(s) when a 'path'
        # to the new site has been provided.
        #   e.g.  jekyll new work/blogs/exploring ruby would install a blog
        #   titled 'Exploring Ruby' at path ~/work/blogs/exploring ruby
        blog_title = extract_title args
        blog_path = File.expand_path(args.join(" "), Dir.pwd)
        FileUtils.mkdir_p blog_path

        if preserve_source_location?(blog_path, options)
          Jekyll.logger.abort_with "Conflict:",
                    "#{blog_path} exists and is not empty."
        end

        create_site blog_title, blog_path, options
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
      def extract_title(args)
        a = args.join(" ").tr("\\", "/").split("/").last
        a.split.map(&:capitalize).join(" ")
      end

      def initialized_post_name
        "_posts/#{Time.now.strftime("%Y-%m-%d")}-welcome-to-jekyll.md"
      end

      def initialize_git(path)
        Jekyll.logger.info "Initialising:", File.join(path, ".git") if @verbose
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

      def preserve_source_location?(path, options)
        !options["force"] && !Dir["#{path}/**/*"].empty?
      end

      def create_site(title, path, options)
        if options["blank"] && options["verbose"]
          create_blank_site path
        else
          create_sample_files path
          add_supporting_files title, path, options
        end
        after_install title, path, options
      end

      def create_blank_site(path)
        Dir.chdir(path) do
          FileUtils.mkdir(%w(_layouts _posts _drafts))
          FileUtils.touch("index.html")
        end
      end

      def create_sample_files(path)
        Jekyll.logger.info "" if @verbose
        initialize_git path
        FileUtils.mkdir_p(File.expand_path("_posts", path))
        source = site_template

        static_files = %w(index.md about.md .gitignore)
        static_files.each do |file|
          write_file(file, template(file, source), path)
        end
        write_file(initialized_post_name, template(scaffold_path, source), path)
      end

      # adds Gemfile and _config.yml
      # additionally creates (updated) SCAFFOLD DIRECTORIES of a Jekyll Theme at
      # blog_path when the `--classic` switch is used.
      def add_supporting_files(title, path, options)
        if options["classic"]
          source = classic_template
          Jekyll.logger.info "Creating:", "Classic directories and files" if @verbose
          FileUtils.cp_r "#{classic_directories}/.", path
        else
          source = site_template
        end
        create_config_file title, path, source
        write_file("Gemfile", template("Gemfile.erb", source), path)
        Jekyll.logger.info "" if @verbose
      end

      # create _config.yml pre-populated with blog-title, and author's name & email
      # using information from the user's .gitconfig
      def create_config_file(title, path, source)
        @blog_title = title
        @user_name = user_name
        @user_email = user_email
        config_template = File.expand_path("_config.yml.erb", source)
        config_copy = ERB.new(File.read(config_template)).result(binding)

        Jekyll.logger.info "Creating:", File.join(path, "_config.yml") if @verbose
        File.open(File.expand_path("_config.yml", path), "w") do |f|
          f.write(config_copy)
        end
      end

      def write_file(filename, contents, path)
        full_path = File.expand_path(filename, path)
        Jekyll.logger.info "Creating:", full_path if @verbose
        File.write(full_path, contents)
      end

      def template(filename, source)
        erb ||= ThemeBuilder::ERBRenderer.new(self)
        erb.render(File.read(File.expand_path(filename, source)))
      end

      def site_template
        File.expand_path("../templates/site_template", File.dirname(__FILE__))
      end

      def classic_template
        File.expand_path("../templates/classic_template", File.dirname(__FILE__))
      end

      def classic_directories
        File.join(classic_template, "theme_folders")
      end

      def scaffold_path
        "_posts/0000-00-00-welcome-to-jekyll.md.erb"
      end

      # After a new blog has been installed, print a success notification and then
      # automatically execute bundle install from within the new blog dir unless
      # the user opts to generate a classic Jekyll blog or a blank blog or skip
      # 'bundle install' using the `--skip-bundle` switch
      def after_install(title, path, options)
        if options["classic"]
          Jekyll.logger.info "New classic jekyll site installed in #{path.cyan}."
        elsif options["blank"]
          Jekyll.logger.info "New blank jekyll site installed in #{path.cyan}."
        else
          Jekyll.logger.info "New jekyll site #{title.cyan} installed in #{path.cyan}."
        end

        Jekyll.logger.info "Bundle install skipped." if options["skip-bundle"]
        unless options["classic"] || options["blank"] || options["skip-bundle"]
          bundle_install path
        end
      end

      def bundle_install(path)
        Jekyll::External.require_with_graceful_fail "bundler"
        Jekyll.logger.info "Running bundle install in #{path.cyan}..."
        Dir.chdir(path) do
          if ENV["CI"]
            system("bundle", "install", "--quiet")
          else
            system("bundle", "install")
          end
        end
      end
    end
  end
end
