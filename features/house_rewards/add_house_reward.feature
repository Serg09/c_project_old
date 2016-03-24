Feature: Add a house-fulfilled reward
  As an administrator
  In order to make a house-fulfilled reward available for an author to select
  I need to be able to add one

  Scenario: An administrator adds a house-fulfilled reward
    Given there is an administrator with email "joe@admin.com" and password "please01"
    And I am signed in as an administrator with "joe@admin.com/please01"

    When I am on the administration home page
    Then I should see "Rewards" within the main menu

    When I click "Rewards" within the main menu
    Then I should see "Rewards" within the page title
    And I should see the following rewards table
      | Description | Address Req.? |

    When I click "Add" within the admin content
    And I fill in "Description" with "Autographed 'thank you' letter from Christian"
    And I check "Physical address required"
    And I click "Save"
    Then I should see "The reward was created successfully." within the notifications area
    And I should see the following rewards table
      | Description                                   | Address Req.? |
      | Autographed 'thank you' letter from Christian |               |


