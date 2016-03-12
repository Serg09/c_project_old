Feature: Add a campaign
  As an author
  In order to raise money for a book I want to write
  I need to be able to create a campaign for the book

  Scenario: An author successfully creates a campaign for a book
    Given there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has an approved book titled "Things I Know That You Don't"
    And I am signed in as an author with "john@doe.com/please01"
    And today is 3/2/2016

    When I am on the author home page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title                        |
      | Things I Know That You Don't |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for Things I Know That You Don't" within the page title

    And I should see the following campaigns table
      | Target date | Target amount |

    When I click "Add" within the main content
    Then I should see "Add campaign for Things I Know That You Don't" within the page title

    When I fill in "Target amount" with "5000"
    And I fill in "Target date" with "4/30/2016"
    And I click "Save"
    Then I should see "The campaign was created successfully." within the notification area
    Then I should see "Campaigns for Things I Know That You Don't" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   4/30/2016 |        $5,000 |
