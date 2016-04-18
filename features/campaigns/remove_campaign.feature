Feature: Remove a campaign
  As an author
  In order to discard a campaign I do not need
  I need to be able to remove it from the system

  Scenario: An author successfully removes a scenario
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has an approved book titled "Words and Things"
    And author john@doe.com has an unstarted campaign for "Words and Things" targeting $5,000 by 4/30/2016
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

    When I click the delete button within the 1st campaign row
    When I should see "The campaign was removed successfully" within the notification area
    And I should see the following campaigns table
      | Target date | Target amount |
