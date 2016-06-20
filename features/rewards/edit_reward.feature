Feature: Edit a reward
  As an author
  In order to enhance the incentive to donate to my book campaign
  I need to be able to edit a reward

  Background:
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has a book titled "Giving It Away"
    And book "Giving It Away" has an unstarted campaign targeting $1,000 by 4/30/2016
    And I am signed in as an author with "john@doe.com/please01"

  Scenario: An author edits an existing author-fulfilled reward
    Given the campaign for book "Giving It Away" has the following rewards
      | Description   | Minimum contribution |
      | Signed copy   |               20 |
      | Blank copy    |               10 |

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
      | Signed copy   |              $20 |

    When I click the edit button within the 1st reward row
    Then I should see "Edit reward" within the page title
    When I fill in "Description" with "Electronic copy"
    And I fill in "Minimum contribution" with "9"
    And I click "Save"
    Then I should see "Campaign for Giving It Away" within the page title
    And I should see "The reward was updated successfully." within the notification area
    And I should see the following rewards table
      | Description     | Minimum contribution |
      | Electronic copy |               $9 |
      | Signed copy     |              $20 |

  Scenario: An author edits an existing house-fulfilled reward
    Given there are the following house rewards
      | Description              |
      | Printed copy of the book |
      | Token of gratitude       |
    And the campaign for book "Giving It Away" has the following rewards
      | Description              | Minimum contribution | House reward             |
      | Signed copy              |               20 |                          |
      | Printed copy of the book |               10 | Printed copy of the book |

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
      | Description              | Minimum contribution |
      | Printed copy of the book |              $10 |
      | Signed copy              |              $20 |

    When I click the edit button within the 1st reward row
    Then I should see "Edit reward" within the page title
    When I select "Token of gratitude" from "Reward"
    And I fill in "Minimum contribution" with "11"
    And I click "Save"
    Then I should see "Campaign for Giving It Away" within the page title
    And I should see "The reward was updated successfully." within the notification area
    And I should see the following rewards table
      | Description        | Minimum contribution |
      | Token of gratitude |              $11 |
      | Signed copy        |              $20 |

  Scenario: An author attempts to edit a reward that has already been promised
    Given the campaign for book "Giving It Away" has the following rewards
      | Description   | Minimum contribution |
      | Signed copy   |               20 |
      | Blank copy    |               10 |
    And the campaign for the book "Giving It Away" has received the following contributions
      | Amount | Reward      |
      |    100 | Signed copy |

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
      | Signed copy   |              $20 |
    And I should see a delete button within the 1st reward row
    And I should not see a delete button within the 2nd reward row
