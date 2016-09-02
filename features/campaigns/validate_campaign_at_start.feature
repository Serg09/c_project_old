Feature: Validate a campaign at start
  As an author
  In order to know if my campaign does not meet any requirements at start time
  I want to see validation messages explaining the failures

  Scenario: An author starts a campaign with less than 30 days until the target date
    Given today is 1/1/2016
    And there is an author with email "john@doe.com" and password "please01"
    And user john@doe.com has an approved bio
    And user john@doe.com has a book titled "Avoiding Procrastination"
    And the book "Avoiding Procrastination" has a unstarted campaign targeting $1,000 by 1/31/2016

    When it is 1/15/2016
    And I am signed in as an author with "john@doe.com/please01"
    And I am on the author home page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title                    |
      | Avoiding Procrastination |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for Avoiding Procrastination" within the page title
    And I should see the following campaigns table
      | Target date | Target amount | State     |
      |   1/31/2016 |        $1,000 | unstarted |

    When I click the start button within the 1st campaign row
    Then I should see "Campaign terms of use" within the page title

    When I check "I agree"
    And I click "Start"
    Then I should see "Campaign for Avoiding Procrastination" within the page title
    And I should see "The target date must be at least 30 days in the future"
