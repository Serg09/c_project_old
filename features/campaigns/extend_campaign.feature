Feature: Extend a campaign
  As an author
  In order to allow more time for a campaign to be successful
  I want to be able to extend the target date into the future

  @wip
  Scenario: An author exents a campaign
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has a book titled "Just a Little Bit Longer"
    And book "Just a Little Bit Longer" has a campaign targeting $1,000 by 4/30/2016
    And I am signed in as an author with "john@doe.com/please01"

    When I am on the author home page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title                    |
      | Just a Little Bit Longer |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for Just a Little Bit Longer" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   4/30/2016 |        $1,000 |

    When I click the progress button within the 1st campaign row
    Then I should see "Campaign progress" within the page title

    When I click "Extend" within the main content
    Then I should see "The campaign was extended successfully" within the notification area

    When I click "Back"
    Then I should see "Campaigns for Just a Little Bit Longer" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   5/15/2016 |        $1,000 |
