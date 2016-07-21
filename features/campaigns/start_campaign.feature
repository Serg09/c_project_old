Feature: Start a campaign
  As an author
  In order to begin collecting contributions
  I need to be able to start the campaign

  Background:
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has an approved bio
    And author john@doe.com has an approved book titled "Things I Know That You Don't"
    And the book "Things I Know That You Don't" has a unstarted campaign targeting $1,000 by 4/30/2016
    And I am signed in as an author with "john@doe.com/please01"

    When I am on my profile page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title                        |
      | Things I Know That You Don't |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for Things I Know That You Don't" within the page title
    And I should see the following campaigns table
      | Target date | Target amount | State     |
      |   4/30/2016 |        $1,000 | unstarted |

    When I click the start button within the 1st campaign row
    Then I should see "Campaign terms of use" within the page title

  Scenario: An author starts a campaign
    When I check "I agree" within the standard terms section
    And I click "Start"
    Then I should see "Campaign progress" within the page title
    And I should see "The campaign was started successfully" within the notification area

  Scenario: An author tries to start a campaign without agreeing to terms
    When I click "Start"
    Then I should see "Campaign terms of use" within the page title
    And I should see "You must agree to the terms to continue" within the notification area
