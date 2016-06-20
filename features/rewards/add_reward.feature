Feature: Add a reward
  As an author,
  In order to provide incentive for people to support my book project
  I want to be able to offer a gift in return for a contribution of a minimum amount

  Background:
    Given today is 3/2/2016
    And there are the following house rewards
      | Description                 |
      | Printed copy of the book    |
      | Electronic copy of the book |

    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has a book titled "How To Raise Money"
    And book "How To Raise Money" has an unstarted campaign targeting $1,000 by 4/30/2016
    And I am signed in as an author with "john@doe.com/please01"

    When I am on my profile page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title              |
      | How To Raise Money |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for How To Raise Money" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   4/30/2016 |        $1,000 |

    When I click the edit button within the 1st campaign row
    Then I should see "Campaign for How To Raise Money" within the page title
    And I should see the following rewards table
      | Description | Minimum contribution |

    When I click "Add" within the rewards section
    Then I should see "New reward" within the page title

  Scenario: An author adds an author-fulfilled reward to a campaign
    When I fill in "Description" with "Signed copy of the book"
    And I fill in "Minimum contribution" with "50" within the author fulfilled section
    And I check "Physical address required"
    And I click "Save" within the author fulfilled section
    Then I should see "The reward was created successfully." within the notification area
    And I should see the following rewards table
      | Description             | Minimum contribution |
      | Signed copy of the book |              $50 |

  Scenario: An author adds a house-fulfilled reward to the campaign
    When I select "Printed copy of the book" from "Reward"
    And I fill in "Minimum contribution" with "50" within the house fulfilled section
    And I click "Save" within the house fulfilled section
    Then I should see "The reward was created successfully." within the notification area
    And I should see the following rewards table
      | Description              | Minimum contribution |
      | Printed copy of the book |              $50 |
