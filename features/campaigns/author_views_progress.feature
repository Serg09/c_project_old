Feature: View progress of a campaign as an author
  As an author
  In order to see how my campaign is performing
  I need to be able to see the progress

  Scenario: An author views the progress of his campaign
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has an approved book titled "How to Raise Money"
    And author john@doe.com has a campaign for "How to Raise Money" targeting $1,000 by 4/30/2016
    And the campaign for the book "How to Raise Money" has received the following contributions
      | Email          |      Date | Amount |
      | user1@user.com | 2/28/2016 |  50.00 |
      | user2@user.com |  3/1/2016 | 100.00 |
      | user3@user.com |  3/2/2016 |  25.00 |

    When I am signed in as an author with "john@doe.com/please01"
    And I am on the welcome page
    Then I should see "Books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title              |
      | How to Raise Money |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for How to Raise Money" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   4/30/2016 |        $1,000 |

    When I click the progress button within the 1st campaign row
    Then I should see "Campaign progress" within the page title
    And I should see the following campaign progress table
      | Goal           | $1,000 |
      | Contributions  |      3 |
      | Raised         |   $175 |
      | Still need     |   $825 |
      | Days remaining |     59 |
