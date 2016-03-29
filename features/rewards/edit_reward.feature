@wip
Feature: Edit a reward
  As an author
  In order to enhance the incentive to donate to my book campaign
  I need to be able to edit a reward

  Scenario: An author edits an existing author-fulfilled reward
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has a book titled "Giving It Away"
    And book "Giving It Away" has a campaign targeting $1,000 by 4/30/2016
    And the campaign for book "Giving It Away" has the following rewards
      | Description   | Minimum donation |
      | Signed copy   |               20 |
      | Blank copy    |               10 |
    And I am signed in as an author with "john@doe.com/please01"

    When I am on the author home page
    Then I should see "My books" within the main menu
    
    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title          |
      | Giving It Away |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for Giving It Away" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   4/30/2016 |        $1,000 |

    When I click the edit button within the 1st campaign row
    Then I should see "Campaign for Giving It Away" within the page title
    And I should see the following rewards table
      | Description   | Minimum donation |
      | Blank copy    |              $10 |
      | Signed copy   |              $20 |

    When I click the edit button within the 1st reward row
    Then I should see "Edit reward" within the page title
    When I fill in "Description" with "Electronic copy"
    And I fill in "Minimum donation" with "9"
    And I click "Save"
    Then I should see "Campaign for Giving It Away" within the page title
    And I should see "The reward was updated successfully." within the notification area
    And I should see the following rewards table
      | Description     | Minimum donation |
      | Electronic copy |               $9 |
      | Signed copy     |              $20 |
