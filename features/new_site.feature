Feature: Generate a new Jekyll Site
  As a hacker who likes to blog
  I want to be able to make a static site
  In order to share my awesome ideas with the interwebs

  Scenario: Generating a site with no arguments
    Given I do not have a "test-site" directory
    When I run jekyll+ new-site
    Then I should get a non-zero exit status
    And I should see "You must specify a path." in the build output

  Scenario: Generating a default site
    Given I do not have a "test-site" directory
    When I run jekyll+ new-site test-site
    Then I should get a zero exit status
    And the test-site/_posts directory should exist
    And the "test-site/about.md" file should exist
    And the "test-site/index.html" file should exist
    And I should see "gem \"minima\"" in "test-site/Gemfile"
    And I should see "theme: minima" in "test-site/_config.yml"

  Scenario: Generating a site in an existing location that is not empty
    Given I have a test-site directory
    And I have a "test-site/index.md" file that contains "some random text"
    When I run jekyll+ new-site test-site
    Then I should get a non-zero exit status
    And I should see "Conflict: ..." in the build output
    And the test-site/_posts directory should not exist
    And the "test-site/index.html" file should not exist

  Scenario: Generating a site in an existing location successfully
    Given I have a test-site directory
    And I have a "test-site/index.md" file that contains "some random text"
    When I run jekyll+ new-site test-site --force
    Then I should get a zero exit status
    And I should see "New jekyll site..." in the build output
    And the test-site/_posts directory should exist
    And the "test-site/about.md" file should exist
    And the "test-site/index.html" file should exist
    And I should see "gem \"minima\"" in "test-site/Gemfile"
    And I should see "theme: minima" in "test-site/_config.yml"

  Scenario: Generating a site with a custom-theme
    Given I do not have a "test-site" directory
    When I run jekyll+ new-site test-site --theme test-theme
    Then I should get a zero exit status
    And the test-site/_posts directory should exist
    And the "test-site/about.md" file should exist
    And the "test-site/index.html" file should exist
    And I should see "gem \"test-theme\"" in "test-site/Gemfile"
    And I should see "theme: test-theme" in "test-site/_config.yml"

  Scenario: Generating a site with a custom-theme from custom scaffold directory
    Given I do not have a "test-site" directory
    When I run jekyll+ new-site test-site --theme another-test-theme
    Then I should get a zero exit status
    And the test-site/_posts directory should exist
    But the "test-site/about.md" file should not exist
    And the "test-site/index.html" file should not exist
    But the "test-site/about-us.md" file should exist
    And the "test-site/index.md" file should exist
    And I should see "gem \"another-test-theme\"" in "test-site/Gemfile"
    And I should see "theme: another-test-theme" in "test-site/_config.yml"

  Scenario: Generating a legacy-style site with a custom-theme
    Given I do not have a "test-site" directory
    When I run jekyll+ new-site test-site --classic --theme test-theme
    Then I should get a zero exit status
    And the test-site/_posts directory should exist
    And the "test-site/about.md" file should exist
    And the "test-site/index.html" file should exist
    And I should see "default.html from test-theme" in "test-site/_layouts/default.html"
    And I should see "include.html from test-theme" in "test-site/_includes/include.html"
    And I should see ".sample {\n" in "test-site/_sass/test-theme-black.scss"
    And I should see "gem \"test-theme\"" in "test-site/Gemfile"
    And I should see "theme: test-theme" in "test-site/_config.yml"
