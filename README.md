# Jekyll-Plus

[![Gem Version](https://img.shields.io/gem/v/jekyll-plus.svg)](https://rubygems.org/gems/jekyll-plus)
[![Build Status](https://img.shields.io/travis/ashmaroli/jekyll-plus/master.svg?label=Build%20Status)][travis]

[travis]: https://travis-ci.org/ashmaroli/jekyll-plus

A ruby gem that modifies `jekyll new` command to add new switches: `--plus`, `--classic`, `--verbose`.

## Installation

Simply run:

    $ gem install jekyll-plus

Currently, to use this gem as intended, Jekyll's native `~/commands/new.rb` file requires to be slightly modified as shown below:
```diff
# lib/jekyll/commands/new.rb

def init_with_program(prog)
  prog.command(:new) do |c|
    c.syntax "new PATH"
    c.description "Creates a new Jekyll site scaffold in PATH"

    c.option "force", "--force", "Force creation even if PATH already exists"
    c.option "blank", "--blank", "Creates scaffolding but with empty files"
    c.option "skip-bundle", "--skip-bundle", "Skip 'bundle install'"
+   c.option "plus", "--plus", "Plus features"
+   c.option "classic", "--classic", "Classic Jekyll scaffolding"
+   c.option "verbose", "--verbose", "Output messages while creating"

    c.action do |args, options|
+     if options["plus"] || options["classic"] || options["verbose"]
+       External.require_with_graceful_fail "jekyll-plus"
+     end
      Jekyll::Commands::New.process(args, options)
    end
  end
end
```
## Usage

This gem provides three new switches to be used along with the `jekyll new` command.

### `--plus`

This switch creates a new Jekyll site using ERB templates for `_config.yml` and `Gemfile` and additionally initializes the directory as a git repository.  
The config file in such sites will be **pre-populated** with information from the argument(s) passed to `jekyll new` and from the user's `.gitconfig` file. If the git-user-details have not been configured, placeholder text will be used instead.

**Note:** `site.title` will be set with `capitalized` version of the project's directory-name.  
This switch has no effect when used alongside the `--blank` switch.

### `--classic`

This switch creates a classic-style (pre-Jekyll-3.2) Jekyll site by including the `_layouts`, `_includes`, `_sass` at the root. The directory structure has been altered to be in sync with Jekyll v3.3 and hence you'll have a `Gemfile`, `css/main.scss` is now `assets/main.scss`, etc.

A *Classic Site* will:
  - have `Gemfile` and `_config.yml` with the line containing `minima` commented out.
  - have `_layouts`, `_includes`, `_sass` and `assets` at root.
  - the contents of these directories, in sync (to be manually updated with patch releases) with the latest `master` branch from Minima Repo.
  - ***not*** have `site.email` and `site.author` pre-filled with info from user's `.gitconfig` or `site.title` pre-configured from the argument(s) passed.
  - ***not*** run `bundle install` automatically.

**Note:** `--classic` dominates `--plus` and will create a *Classic Site* when the two switches are used together.

### `--verbose`

This switch prints out messages as the new Jekyll site is being created. Can be used with `--blank`, `--plus` and `--classic`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ashmaroli/jekyll-plus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
