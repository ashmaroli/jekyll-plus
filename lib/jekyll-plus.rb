require "jekyll"
require "jekyll-plus/version"
require_relative "jekyll/commands/new_site"
require_relative "jekyll/commands/extract_theme"

# Plugins
require "jekyll-data" # read "_config.yml" and data files within a theme-gem

# ------------------------------ Temporary Patches ------------------------------
# TODO:
#   - remove patch to Jekyll Configuration after jekyll/jekyll/pull/5487 is merged.

require_relative "patches/idempotent_jekyll_config"

# --------------------------- End of Temporary Patches ---------------------------
