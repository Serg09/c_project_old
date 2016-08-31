Feature: Add an author
  As an administrator
  In order to make author information availabel without a corresponding user account
  I need to be able to add an author

  Scenario: An administrator adds an author
    Given there is an administrator with email "john@doe.com" and password "please01"

    When I am signed in as an administrator with "john@doe.com/please01"
    And I am on the administration home page
    Then I should see "Authors" within the main menu

    When I click "Authors" within the main menu
    Then I should see "Authors" within the page title

    When I click "Add" within the admin content
    Then I should see "New author" within the page title

    When I fill in "First name" with "Earnest"
    And I fill in "Last name" with "Hemingway"
    And I click "Save"
    Then I should see "The author was created successfully" within the notification area
    And I should see "Authors" within the page title
    And I should see the following author table
      | Last name | First name |
      | Hemingway | Earnest    |
