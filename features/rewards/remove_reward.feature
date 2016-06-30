Feature: Remove a reward
  As an author
  In order to adjust my incentives for donors
  I need to be able to remove a reward

  Background:
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has a book titled "Giving It Away"
    And book "Giving It Away" has an unstarted campaign targeting $1,000 by 4/30/2016
    And the campaign for book "Giving It Away" has the following rewards
      | Description   | Minimum contribution |
      | Signed copy   |               20 |
      | Unsigned copy |               15 |
      | Blank copy    |               10 |
    And I am signed in as an author with "john@doe.com/please01"

  Scenario: An author removes an existing reward
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
      | Description   | Minimum contribution |
      | Blank copy    |              $10 |
      | Unsigned copy |              $15 |
      | Signed copy   |              $20 |

    When I click the delete button within the 2nd reward row
    Then I should see "Campaign for Giving It Away" within the page title
    And I should see "The reward was removed successfully" within the notification area
    And I should see the following rewards table
      | Description   | Minimum contribution |
      | Blank copy    |              $10 |
      | Signed copy   |              $20 |

  Scenario: An author attempts to remove a reward that has already been selected
    Given the campaign for the book "Giving It Away" has received the following contributions
      | Email                     | Amount |     Date | Reward        |
      | sally.readerton@gmail.com |    100 | 4/1/2016 | Unsigned copy |

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
      | Description   | Minimum contribution |
      | Blank copy    |              $10 |
      | Unsigned copy |              $15 |
      | Signed copy   |              $20 |
    And I should not see a delete button within the 2nd reward row
