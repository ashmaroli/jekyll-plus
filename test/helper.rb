require "rubygems"
require "jekyll"
require "minitest/autorun"
require "minitest/reporters"
require "minitest/profile"
require "rspec/mocks"
require "shoulda"
require_relative "../lib/jekyll-plus.rb"

# Report with color.
Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(
    :color => true
  ),
]

module Minitest::Assertions
  def assert_exist(filename, msg = nil)
    msg = message(msg) { "Expected '#{filename}' to exist" }
    assert File.exist?(filename), msg
  end

  def refute_exist(filename, msg = nil)
    msg = message(msg) { "Expected '#{filename}' not to exist" }
    refute File.exist?(filename), msg
  end
end

Jekyll.logger = Logger.new(StringIO.new)

class JekyllPlusTest < Minitest::Test
  include ::RSpec::Mocks::ExampleMethods
  include Jekyll

  def before_setup
    RSpec::Mocks.setup
    super
  end

  def after_teardown
    super
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end

  def capture_output
    stderr = StringIO.new
    Jekyll.logger = Logger.new stderr
    yield
    stderr.rewind
    return stderr.string.to_s
  end
  alias_method :capture_stdout, :capture_output
  alias_method :capture_stderr, :capture_output
end
