module Jekyll
  class Commands::ExtractTheme < Command
    class << self
      def init_with_program(prog)
        prog.command(:"extract-theme") do |c|
          c.syntax      "extract-theme [DIR (or) FILE-PATH]"
          c.description "Extract files and directories from theme-gem to Source"
          c.alias :extract

          c.option "force", "--force", "Force extraction even if file already exists"
          c.option "list", "--list", "List the contents of the specified [DIR]"
          c.option "lax", "--lax", "Continue extraction process if a file doesn't exist"
          c.option "root", "--root", "Extract sub-directory contents directly to Source"
          c.option "quiet", "--quiet", "Swallow info messages while extracting"
          c.option "verbose", "--verbose", "Additional info messages while extracting"

          c.action do |args, options|
            if args.empty?
              raise ArgumentError, "You must specify a theme directory or a file path."
            end
            process(args, options)
          end
        end
      end

      def process(args, options = {})
        @quiet = options["quiet"]
        @verbose = options["verbose"]

        config = if @quiet
                   get_configuration_from "_config.yml"
                 else
                   Jekyll.configuration(Configuration.new)
                 end
        @source = config["source"]
        @theme_dir = Site.new(config).theme.root

        verbose_print "Source Directory:", @source
        verbose_print "Theme Directory:", @theme_dir
        verbose_print ""

        # Substitute leading special-characters in an argument with an
        # 'underscore' to disable extraction of files outside the theme-gem
        # but allow extraction of theme directories with a leading underscore.
        #
        # Process each valid argument individually to enable extraction of
        # multiple files or directories.
        args.map { |i| i.sub(%r!\A\W!, "_") }.each do |arg|
          initiate_extraction arg, options
        end
        verbose_print "", "..done"
      end

      private

      def initiate_extraction(path, options)
        file_path = Jekyll.sanitized_path(@theme_dir, path)
        if File.exist? file_path
          extract_to_source file_path, options
        else
          error_msg = "'#{path}' could not be found at the root of your theme-gem."
          if options["lax"]
            Jekyll.logger.warn "", "#{error_msg} Proceeding anyways."
            verbose_print ""
          else
            Jekyll.logger.abort_with "ERROR:", error_msg
          end
        end
      end

      def extract_to_source(path, options)
        if File.directory?(path)
          process_options_and_extract_directory path, options
        else
          process_options_and_extract_file path, options
        end
      end

      def process_options_and_extract_directory(path, options)
        if options["list"]
          list_contents path
        elsif options["root"]
          extract_dir_contents_to_root path, options
        else
          dir_path = File.expand_path(path.split("/").last, @source)
          extract_directory dir_path, path, options
        end
      end

      def process_options_and_extract_file(path, options)
        if options["list"]
          Jekyll.logger.warn "Error:", relative_path(path)
          Jekyll.logger.warn "", "The --list switch only works for directories"
        elsif options["root"]
          file_path = File.join(@source, File.basename(path))
          extract_unless_exists(file_path, File.basename(path), options) do
            print "Extracting:", relative_path(path)
            FileUtils.cp path, @source
          end
        else
          dir_path = File.dirname(File.join(@source, relative_path(path)))
          extract_file_with_directory dir_path, path, options
        end
      end

      def list_contents(path)
        print ""
        print("Listing:",
          "Contents of '#{relative_path(path)}' in theme gem...")
        print ""
        files_in(path).each do |file|
          print "*", relative_path(file)
        end
      end

      def extract_directory(dir_path, path, options)
        extract_unless_exists(dir_path, path, options) do
          FileUtils.cp_r path, @source
          directory = "#{relative_path(path).sub("/", "")} directory"
          print "Extracting:", directory
          verbose_print "", "-" * directory.length
          files_in(path).each do |file|
            verbose_print "", dir_content_path(path, file)
          end
          verbose_print ""
        end
      end

      def extract_file_with_directory(dir_path, file_path, options)
        FileUtils.mkdir_p dir_path unless File.directory? dir_path
        file = file_path.split("/").last
        extract_unless_exists(File.join(dir_path, file), file, options) do
          FileUtils.cp_r file_path, dir_path
          extraction_msg file_path
        end
      end

      def extract_dir_contents_to_root(path, options)
        if !options["force"]
          Jekyll.logger.warn "Attention:", "Using --root with directories will " \
          "extract contents recursively and override corresponding file paths " \
          "relative to your source directory. Please run the command again with " \
          "an additional --force to confirm."
        elsif options["force"]
          Dir["#{path}/**/*"].each do |entry|
            unless File.directory?(entry)
              if File.exist?(File.join(@source, dir_content(path, entry)))
                Jekyll.logger.warn "Overriding:", dir_content(path, entry)
              else
                print "Extracting:", dir_content(path, entry)
              end
            end
          end
          FileUtils.cp_r "#{path}/.", @source
        end
      end

      def get_configuration_from(file)
        yaml_data = SafeYAML.load_file(file)
        if yaml_data.is_a? Hash
          Configuration.from yaml_data
        else
          Jekyll.logger.abort_with "FATAL:", "Could not extract hash from #{file}"
        end
      end

      def extract_unless_exists(path, file, options)
        if File.exist?(path) && !options["force"]
          already_exists_msg file
        else
          yield
        end
      end

      def files_in(dir_path)
        Dir["#{dir_path}/**/*"].reject { |d| File.directory? d }
      end

      def relative_path(file)
        file.sub(@theme_dir, "")
      end

      def dir_content(dir, file)
        relative_path(file).sub("#{relative_path(dir)}/", "")
      end

      def dir_content_path(dir, file)
        relative_path(file).sub("#{relative_path(dir)}/", " * ")
      end

      def extraction_msg(file)
        print "Extracting:", relative_path(file)
      end

      def already_exists_msg(file)
        Jekyll.logger.warn "Error:", "'#{relative_path(file)}' already exists " \
                           "at destination. Use --force to overwrite."
      end

      def print(topic, message = "")
        unless @quiet
          Jekyll.logger.info topic, message
        end
      end

      # only with --verbose switch
      def verbose_print(topic, message = "")
        if @verbose
          Jekyll.logger.info topic, message
        end
      end
    end
  end
end
