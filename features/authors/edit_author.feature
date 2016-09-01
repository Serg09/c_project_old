Feature: Edit an author
  As an administrator
  In order to keep author information up-to-date
  I need to be able to edit an author

  Scenario: An administrator edits an author
    Given there is an author named "George Orwell"
    And there is an administrator with email "joe@admin.com" and password "please01"
    And I am signed in as an administrator with "joe@admin.com/please01"

    When I am on the administration home page
    Then I should see "Authors" within the main menu

    When I click "Authors" within the main menu
    Then I should see "Authors" within the page title
    And I should see the following authors table
      | Last name | First name |
      | Orwell    | George     |

    When I click the edit button within the 1st author row
    Then I should see "Edit author" within the page title

    When I fill in "First name" with "Eric"
    And I fill in "Last name" with "Blair"
    And I click "Save"
    Then I should see "The author was updated successfully" within the notification area
    And I should see "Authors" within the page title
    And I should see the following authors table
      | Last name | First name |
      | Blair     | Eric       |
