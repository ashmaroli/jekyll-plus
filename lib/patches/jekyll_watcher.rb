require "listen"

module Jekyll
  module Watcher
    extend self

    # Returns nothing.
    def watch(options, site = nil)
      ENV["LISTEN_GEM_DEBUGGING"] ||= "1" if options["verbose"]

      site ||= Jekyll::Site.new(options)
      listener = build_listener(site, options)
      listener.start

      Jekyll.logger.info "Auto-regeneration:", "#{"enabled".green} for #{options["source"]}"

      unless options["serving"]
        trap("INT") do
          listener.stop
          puts "     Halting auto-regeneration."
          exit 0
        end

        sleep_forever
      end
    rescue ThreadError
      # You pressed Ctrl-C, oh my!
    end

    def listen_handler(site)
      proc do |modified, added, removed|
        t = Time.now
        c = modified + added + removed
        n = c.length
        Jekyll.logger.info("Regenerating:",
          "#{n} file(s) changed at #{t.strftime("%Y-%m-%d %H:%M:%S")} ")
        relative_paths = c.map { |p| site.in_source_dir(p) }
        relative_paths.each { |file| Jekyll.logger.info "", file.cyan }
        process site, t
      end
    end

    private

    def process(site, time)
      site.process
      Jekyll.logger.info "", "...done in #{Time.now - time} seconds.".green
      print_clear_line
    rescue => e
      Jekyll.logger.warn "Error:", e.message
      Jekyll.logger.warn "Error:", "Run jekyll build --trace for more information."
      print_clear_line
    end

    def print_clear_line
      Jekyll.logger.info ""
    end
  end
end
