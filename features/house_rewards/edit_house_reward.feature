Feature: Edit a house reward
  As an administrator
  In order to correct or update a house reward
  I need to be able to edit the record

  Scenario: An administrator updates an existing house reward
    Given there is an administrator with email "joe@admin.com" and password "please01"
    And there are the following house rewards
      | Description                 | Physical address required |
      | Printed copy of the bok     |                     false |
      | Electronic copy of the book |                     false |
    And I am signed in as an administrator with "joe@admin.com/please01"

    When I am on the administration home page
    Then I should see "Rewards" within the main menu

    When I click "Rewards" within the main menu
    Then I should see "Rewards" within the page title
    And I should see the following rewards table
      | Description                 | Address Req.? |
      | Printed copy of the bok     |               |
      | Electronic copy of the book |               |

    When I click the edit button within the 1st reward row
    Then I should see "Edit house reward" within the page title

    When I fill in "Description" with "Printed copy of the book"
    And I check "Physical address required"
    And I click "Save"
    Then I should see "Rewards" within the page title
    And I should see "The reward was updated successfully."
    And I should see the following rewards table
      | Description                 | Address Req.? |
      | Printed copy of the book    |               |
      | Electronic copy of the book |               |
