Feature: Edit an author bio
  As an administrator
  In order to supply (or update) a bio for an author that does not have a user account
  I need to be able to edit the bio

  Scenario: Add a new bio
    Given there is an author named "H.G. Wells"
    And there is an administrator with email "joe@admin.com" and password "please01"
    And I am signed in as an administrator with "joe@admin.com/please01"

    When I am on the administration home page
    Then I should see "Authors" within the main menu

    When I click "Authors" within the main menu
    Then I should see "Authors" within the page title
    And I should see the following authors table
      | Last name | First name |
      | Wells     | H.G.       |

    When I click the bio button within the 1st author row
    Then I should see "New author bio" within the page title

    When I fill in "Text" with "Blah blah blah blah"
    And I fill in "Facebook" with "http://www.facebook.com/johndoe"
    And I click "Save"
    Then I should see "The bio was created successfully" within the notification area
    And I should see "Authors" within the page title

  @wip
  Scenario: Edit an existing bio
    Given I still need to write this
