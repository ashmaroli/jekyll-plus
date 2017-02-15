source 'https://rubygems.org'
gemspec

group :test do
  gem "rake"  
  gem "rubocop", "~> 0.47"
  gem "cucumber", "~> 2.1"
  gem "rspec"
  gem "activesupport", "~> 4.2" if RUBY_VERSION < '2.2.2'
  gem "test-theme", path: File.expand_path("./test/fixtures/test-theme", File.dirname(__FILE__))
end
