module Mercenary
  class Presenter
    attr_accessor :command

    def options_presentation
      return nil unless command_options_presentation || parent_command_options_presentation
      [command_options_presentation.cyan, parent_command_options_presentation].join("\n\n").rstrip
    end

    def parent_command_options_presentation
      return nil unless command.parent
      Presenter.new(command.parent).command_options_presentation
    end

    # adapted from https://github.com/jekyll/mercenary/pull/44
    def command_options_presentation
      return nil if command.options.empty?
      command_options = command.options
      command_options -= command.parent.options unless command.parent.nil?
      command_options.map(&:to_s).join("\n")
    end

    def command_header
      header = "\n#{command.identity}"
      header << " -- #{command.description}" if command.description
      header
    end
  end

  class Option
    def formatted_switches
      [
        switches.first.rjust(10),
        switches.last.ljust(20)
      ].join(", ").gsub(/ , /, '   ').gsub(/,   /, '    ')
    end
  end
end
