# JekyllPlus

[![Gem Version](https://img.shields.io/gem/v/jekyll-plus.svg)](https://rubygems.org/gems/jekyll-plus)
[![Build Status](https://img.shields.io/travis/ashmaroli/jekyll-plus/master.svg?label=Build%20Status)][travis]

[travis]: https://travis-ci.org/ashmaroli/jekyll-plus

JekyllPlus is now a tool that simplifies the installation and usage of a Jekyll Site linked to a gem-based Jekyll Theme.
*Disclaimer: This plugin works best with gem-based themes that are [serve-ready packages](#gem-recommendation).*


## Installation

Simply run:

    $ gem install jekyll-plus


## Usage

This gem installs an executable `jekyll+` that takes a couple of new commands to enrich the Jekyll experience.<br>
**Note:** Along with the following commands, all existing Jekyll Commands are available to be used with the executable.<br>
The new additions are :


### `new-site`

```
jekyll+ new-site -- Creates a custom Jekyll site scaffold in PATH

Usage:

  jekyll+ new-site PATH

Options:
          --classic          Classic Jekyll scaffolding
          --theme GEM-NAME   Scaffold with a custom gem-based theme
          --force            Force creation even if PATH already exists
          --verbose          Output messages while creating

```

#### Overview

`jekyll+ new-site` is very much like `jekyll new` in that it generates a static-site precursor to be processed into an HTML website. But its also very different in the sense that `new-site` **deviates from Jekyll's no-magic philosophy**

A default site generated by `new-site` will have the site's `title` configured based on the `PATH` argument supplied.

```sh

$ jekyll+ new-site my blog
# => New jekyll site (titled) My Blog installed in ~/my blog.

```

```sh

$ jekyll+ new-site blogs/summer rain
# => New jekyll site (titled) Summer Rain installed in ~/blogs/summer rain.

```
If the user has Git installed and configured on their system, another set of keys are automatically defined &mdash; `name:` and `email:`, both of which will now be populated with the corresponding Git credentials.

This auto-populate feature extends to sites generated with `--classic` and `--theme` switches **if the theme-gem doesn't bundle a `_config.yml` within it**.

--

The `--theme` switch is for those who have decided what **theme-gem** to use with their site.<br>
Simply provide the theme's `gem-name`.<br>
  e.g. To install a site with the **gem-based version** of the popular theme [Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes), (`minimal-mistakes-jekyll`), simply run

    $ jekyll+ new-site awesome blog --theme minimal-mistakes-jekyll

If you have an older version of the theme-gem already installed on your system, then though a new site will be immediately installed at `./awesome blog`, with the `_config.yml` and `Gemfile` already set to use this theme, the downside is that you'll still have to manually download the Minimal-Mistakes-config-file from the theme repo to be *serve-ready*

But if you have installed the [**serve-ready**](#gem-recommendation) version of the theme-gem, then by simply running the command stated above, the new site installed at `./awesome blog` will have the minimum required elements to let you serve and preview the site immediately &mdash; a Minimal-Mistakes-config-file that has all the settings for your site and the associated template files.<br>
The data files need not be copied over to the `source` unless they need to be customized. Data files within the theme-gem will be read like the remaining template files via the built-in [`jekyll-data`](https://github.com/ashmaroli/jekyll-data) plugin.

If you dont have any version of the theme installed, then `new-site` will automatically run `bundle install` and install the latest version available if you're connected to the internet.

--

When the `--classic` switch is used, the generated site will contain all the directories expected in a Jekyll installation prior to Jekyll v3.2<br>
The `--classic` and `--theme` switch can be used together to install a classic-style site with the template files and directories extracted to your `source` from the theme-gem.


#### Key Points:

  * `new-site` when passed without the `--classic` or the `--theme` switch doesn't run `bundle install` at the end.

  * if either `--classic` or `--theme` is used, JekyllPlus will first check if the theme-gem (defaults to "minima") is installed in the system. If not found, then it'll initiate `bundle install` to install the theme-gem.

  * the `--classic` switch will run the `extract-theme` command (described below) and copy the theme's template directories and files to the site's default `source` directory. Additionally, if the theme-gem has included a `_config.yml` within it, it will be copied over too, **replacing the one currently present at `source`.**

  * the `--theme` switch will initialize a `Gemfile` and a `_config.yml` with the provided `GEM-NAME`. Additionally, this too will **replace the `_config.yml` at `source` if a namesake is present at the root of the theme-gem.**

--

### `extract-theme`

```
jekyll+ extract-theme -- Extract files and directories from theme-gem to source

Alias: extract

Usage:

  jekyll+ extract-theme [DIR (or) FILE-PATH]
  jekyll+ extract [DIR (or) FILE-PATH]

Options:
          --force     Force extraction even if file already exists
          --list      List the contents of the specified [DIR]
          --lax       Continue extraction process if a file doesn't exist
          --quiet     Swallow info messages while extracting
          --verbose   Additional info messages while extracting

```
`extract-theme` or `extract` does just one thing &mdash; ***copy** files or entire directories from the configured theme-gem to the site's `source` directory.* You can *extract* any combination of files and directories *within the theme-gem* as long as you know their path, relative to the theme-gem.

**Example scenario: &mdash; Extracting the theme's layouts**

  * Lets first inspect the contents of the `_layouts` directory.

  ```sh
  $ bundle exec jekyll+ extract-theme _layouts --list
  # =>
      Listing: Contents of '/_layouts' in theme gem...

             * /_layouts/default.html
             * /_layouts/home.html
             * /_layouts/page.html
             * /_layouts/post.html
               ..done
  ```

  * Now I know what layouts are available. To *extract* the entire `_layouts` directory

  ```sh
  bundle exec jekyll+ extract-theme _layouts
  ```

  * Or, to simply *extract* the layouts for posts and pages:

  ```sh
  bundle exec jekyll+ extract-theme _layouts/page.html _layouts/post.html
  ```

  * To *extract* whatever is available under the `assets` directory and the `post.html` layout:

  ```sh
  bundle exec jekyll+ extract-theme assets _layouts/post.html
  ```

  * Any file within the theme-gem can be *extracted* to `source`.

  ```sh
  bundle exec jekyll+ extract-theme read-me.html
  ```


## Gem Recommendation

The only functional difference between `jekyll new` and **`jekyll+ new-site`** is that the latter's `--theme` and `--classic` switches revolve around a jekyll theme-gem (either the default theme-gem "minima" or the string passed to `--theme`.)

The following are a set of recommendations directed at theme-gem developers to make their themes **serve-ready**:

  * **Serve-ready theme-gems contain all the minimum elements that are required to let the consumer easily preview their site by simply running `bundle exec jekyll+ serve`**

  * If your theme is dependent on a custom **`_config.yml`** that declares necessary plugins and other settings, then please don't hesitate from bundling that file within your theme-gem. `jekyll+ new-site` will then automatically **replace** the **`_config.yml`** at `source` with your bundled file. **You just need to make sure that the `theme` key is properly defined.**

  * If your theme-gem requires a set of data files that impart locale-configuration (they seldom require customization), bundle them into the gem. They will be *read-in* via the included [`jekyll-data`](https://github.com/ashmaroli/jekyll-data) plugin if the user decides to `build` their site locally using `jekyll+ build` or `jekyll+ serve`.

  * If your theme-gem requires certain *customizable* `data files` to exist at `source`, again, pack in the `_data` directory. It can be easily sent to your user's `source` by having them simply run `jekyll+ extract-theme _data` or `jekyll+ extract _data`. Your theme's documentation may need to instruct the user to use that command.

  * Except for `index.html`, files generated by `jekyll+ new-site` do not have the `layout:` key hard-coded in the FrontMatter and hence one can easily bootstrap a site with a theme-gem provided that the theme-gem's `_config.yml` has the **Front Matter Defaults** defined, for example:

  ```yaml
  defaults:
    - scope:
        path: ""
        type: posts
      values:
        layout: post
    - scope:
        path: ""
        type: pages
      values:
        layout: page
  ```

  * `index.html` will take on the values defined for `pages` and hence the `layout` is set to `home` by default.


## Plugins & Patches

  * Includes the [`jekyll-data`](https://github.com/ashmaroli/jekyll-data) plugin that enables reading of data files and `_config.yml` within the theme-gem.
  * Includes patches to various modules and classes used by `Jekyll` adapted from certain existing pull-requests at their respective repos and will be altered / removed as required in future releases.  
  For details, please [refer this file](https://github.com/ashmaroli/jekyll-plus/blob/master/lib/jekyll-plus.rb#L9-L28).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ashmaroli/jekyll-plus.<br>
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
