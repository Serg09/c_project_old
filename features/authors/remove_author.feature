Feature: Remove an author
  As an administrator
  In order to correct a mistake
  I need to be able to remove an author

  Scenario: An administrator removes an author
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

    When I click the delete button within the 1st author row
    Then I should see "The author was removed successfully" within the notification area
    And I should see "Authors" within the page title
    And I should see the following authors table
      | Last name | First name |
