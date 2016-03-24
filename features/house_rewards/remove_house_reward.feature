Feature: Remove house reward
  As an administrator
  In order to keep the rewards organized
  I need to be able to remove unused rewards

  Scenario: An administrator removes an existing house reward
    Given there is an administrator with email "joe@admin.com" and password "please01"
    And there are the following house rewards
      | Description                 | Physical address required |
      | Printed copy of the book    |                      true |
      | Electronic copy of the book |                     false |
    And I am signed in as an administrator with "joe@admin.com/please01"

    When I am on the administration home page
    Then I should see "Rewards" within the main menu

    When I click "Rewards" within the main menu
    Then I should see "Rewards" within the page title
    And I should see the following rewards table
      | Description                 | Address Req.? |
      | Printed copy of the book    |               |
      | Electronic copy of the book |               |

    When I click the delete button within the 2nd reward row
    Then I should see "Rewards" within the page title
    And I should see "The reward was removed successfully" within the notification area
    And I should see the following rewards table
      | Description                 | Address Req.? |
      | Printed copy of the book    |               |
