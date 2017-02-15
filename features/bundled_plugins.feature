Feature: Bundled plugins
  As a hacker who likes added features
  I want to be able to use certain additonal features out-of-the-box
  In order to avoid having to manually include same plugins to every new blog

  Scenario: Building a site with a theme that includes data files
    Given I do not have a "test-site" directory
    When I run jekyll+ new-site test-site --theme test-theme
    Then I should get a zero exit status
    And the test-site directory should exist
    Given I have moved into the "test-site" directory
    And I have a "test.md" page that contains "{{ site.data.locales[site.locale].greeting }}"
    When I run bundle exec jekyll+ build
    Then I should get a zero exit status
    And I should see "<p>Bonjour, Bienvenue!</p>" in "_site/test.html"
