Feature: Edit a campaign
  As an author
  In order to modify, pause, or unpause a campaign
  I need to be able to edit the campaign

  Scenario: An author modifies a campaign
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And user john@doe.com has an approved book titled "Words and Things"
    And user john@doe.com has an unstarted campaign for "Words and Things" targeting $5,000 by 4/30/2016
    And I am signed in as an author with "john@doe.com/please01"

    When I am on the welcome page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title            |
      | Words and Things |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for Words and Things" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   4/30/2016 |        $5,000 |

    When I click the edit button within the 1st campaign row
    Then I should see "Campaign for Words and Things" within the page title

    When I fill in "Target amount" with "5500"
    And I click "Save"
    Then I should see "The campaign was updated successfully" within the notification area
    And I should see "Campaigns for Words and Things" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   4/30/2016 |        $5,500 |
