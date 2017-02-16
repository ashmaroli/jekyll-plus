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

require_relative "patches/idempotent_jekyll_config"

require "mercenary"
require_relative "patches/mercenary_presenter"

# --------------------------- End of Temporary Patches ---------------------------
