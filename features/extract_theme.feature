Feature: Extracting theme contents to source
  As a hacker who likes to customize stuff
  I want to be able to easily obtain files from my theme-gem
  In order to override the default theme layouts and styles

  Scenario: Inspecting the contents of a directory to be extracted
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts --list
    Then I should get a zero exit status
    And I should see "Listing: Contents of '/_layouts' in theme gem..." in the build output
    And I should see "/_layouts/default.html" in the build output

  Scenario: Inspecting the contents of multiple directories to be extracted
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts assets --list
    Then I should get a zero exit status
    And I should see "Listing: Contents of '/_layouts' in theme gem..." in the build output
    And I should see "/_layouts/default.html" in the build output
    And I should see "Listing: Contents of '/assets' in theme gem..." in the build output
    And I should see "/assets/img/logo.png" in the build output
    And I should see "/assets/style.scss" in the build output

  Scenario: Inspecting a file to be extracted
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts/default.html --list
    Then I should get a zero exit status
    And I should see "Error: /_layouts/default.html" in the build output
    And I should see "The --list switch only works for directories" in the build output

  Scenario: Extracting an entire directory
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts
    Then I should get a zero exit status
    And the _layouts directory should exist
    And the "_layouts/default.html" file should exist

  Scenario: Extracting an entire directory with subdirectories
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme assets
    Then I should get a zero exit status
    And the assets directory should exist
    And the "assets/style.scss" file should exist
    And the "assets/img/logo.png" file should exist

  Scenario: Extracting multiple directories
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts assets
    Then I should get a zero exit status
    And the _layouts directory should exist
    And the "_layouts/default.html" file should exist
    And the assets directory should exist
    And the "assets/style.scss" file should exist
    And the "assets/img/logo.png" file should exist

  Scenario: Extracting only a specific file
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme assets/img/logo.png
    Then I should get a zero exit status
    And the assets directory should exist
    And the "assets/img/logo.png" file should exist
    And the "assets/style.scss" file should not exist

  Scenario: Extracting specific files
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts/default.html assets/img/logo.png
    Then I should get a zero exit status
    And the _layouts directory should exist
    And the "_layouts/default.html" file should exist
    And the assets directory should exist
    And the "assets/img/logo.png" file should exist
    And the "assets/style.scss" file should not exist

  Scenario: Extracting a combo of directory and specific files
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts assets/img/logo.png assets/style.scss
    Then I should get a zero exit status
    And the _layouts directory should exist
    And the "_layouts/default.html" file should exist
    And the assets directory should exist
    And the "assets/img/logo.png" file should exist
    And the "assets/style.scss" file should exist

  Scenario: Extracting a file outside the theme-gem
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme ../../pwd
    Then I should get a non-zero exit status

  Scenario: Extracting a non-existent file
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts/test.html
    Then I should get a non-zero exit status
    And I should see "Error: Specified file or directory doesn't exist" in the build output
    And the "_layouts/test.html" file should not exist

  Scenario: Extracting a non-existent file under lax-mode
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme _layouts/test.html --lax
    Then I should get a zero exit status
    And I should not see "Error: Specified file or directory doesn't exist" in the build output
    And the "_layouts/test.html" file should not exist

  Scenario: Extracting a file that already exists at destination
    Given I have a configuration file with "theme" set to "test-theme"
    And I have a _layouts directory
    And I have a "_layouts/default.html" page that contains "test-layout"
    When I run jekyll+ extract-theme _layouts/default.html
    Then I should see "Error: 'default.html' already exists at destination. Use --force to overwrite." in the build output

  Scenario: Extracting a directory that already exists at destination
    Given I have a configuration file with "theme" set to "test-theme"
    And I have a _layouts directory
    When I run jekyll+ extract-theme _layouts
    Then I should see "Error: '/_layouts' already exists at destination. Use --force to overwrite." in the build output

  Scenario: Force extraction of a file that already exists at destination
    Given I have a configuration file with "theme" set to "test-theme"
    And I have a _layouts directory
    And I have a "_layouts/default.html" page that contains "test-layout"
    When I run jekyll+ extract-theme _layouts/default.html --force
    Then I should get a zero exit status
    And I should see "Extract: /_layouts/default.html" in the build output
    And I should see "default.html from test-theme:" in "_layouts/default.html"

  Scenario: Extracting with nothing specified
    Given I have a configuration file with "theme" set to "test-theme"
    When I run jekyll+ extract-theme
    Then I should get a non-zero exit status
    And I should see "Error: You must specify a theme directory or a file path." in the build output
