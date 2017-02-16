module Jekyll
  class Command
    def self.configuration_from_options(options)
      return options if options.is_a?(Jekyll::Configuration)
      Jekyll.configuration(options)
    end
  end

  module Commands
    class Serve < Command
      class << self
        def init_with_program(prog)
          prog.command(:serve) do |cmd|
            cmd.description "Serve your site locally"
            cmd.syntax "serve [options]"
            cmd.alias :server
            cmd.alias :s

            add_build_options(cmd)
            COMMAND_OPTIONS.each do |key, val|
              cmd.option key, *val
            end

            cmd.action do |_, opts|
              opts["serving"] = true
              opts["watch"  ] = true unless opts.key?("watch")

              config = configuration_from_options(opts)
              if Jekyll.env == "development"
                config["url"] = default_url(config)
              end

              Build.process(config)
              Serve.process(config)
            end
          end
        end
      end
    end
  end
end
