require "jekyll"
require "jekyll-plus/version"
require_relative "jekyll/commands/new_site"
require_relative "jekyll/commands/extract_theme"

# Plugins
require "jekyll-data" # read "_config.yml" and data files within a theme-gem

# ------------------------------ Temporary Patches ------------------------------
# TODO:
#   - remove patch to Jekyll Configuration after jekyll/jekyll/pull/5487 is merged.
#   - modify patch to Mercenary after jekyll/mercenary/pull/44 and
#     jekyll/mercenary/pull/48 are merged.
#   - remove patch to Jekyll::Watcher after jekyll/jekyll-watch/pull/42 is merged.
#   - remove patch to Listen Adapter only if any issues regarding that crop up.

require_relative "patches/idempotent_jekyll_config"

require "mercenary"
require_relative "patches/mercenary_presenter"

require "jekyll-watch"
require_relative "patches/jekyll_watcher"

require "listen"
require_relative "patches/listen_windows_adapter"

# --------------------------- End of Temporary Patches ---------------------------
