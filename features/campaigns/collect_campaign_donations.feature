Feature: Collect campaign donations
  As an author
  In order to proceed with a supported project
  I need to be able to collect the promised donations

  Background:
    Given today is 2/27/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has a book titled "Show Me the Money"
    And the book "Show Me the Money" has a campaign targeting $1,000 by 3/31/2016

    When it is 4/1/2016
    And the campaign for the book "Show Me the Money" has received the following donations
      |     Date | Amount |
      | 3/1/2016 |    350 |
      | 3/2/2016 |    400 |
      | 3/9/2016 |    200 |
    And I am signed in as an author with "john@doe.com/please01"
    And I am on the author home page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title             |
      | Show Me the Money |

    When I click the campaigns button within the 1st book row
    Then I should see "Campaigns for Show Me the Money" within the page title
    And I should see the following campaigns table
      | Target date | Target amount |
      |   3/31/2016 |        $1,000 |

    When I click the progress button within the 1st campaign row
    Then I should see "Campaign progress" within the page title
    And I should see the following campaign progress table
      | Goal           | $1,000 |
      | Donations      |      3 |
      | Raised         |   $950 |
      | Still need     |    $50 |
      | Days remaining |      0 |

  @wip
  Scenario: An author collects donations on a campaign
    When I click "Collect"
    Then I should see "The campaign was closed successfully." within the notifications area
    And I should see "This campaign is closed and the funds are being collected. You will be notified when the collection process is complete." within the main content
    And "john@doe.com" should receive an email with the subject "Campaign closed"

    When donation collection has finished for the book "Show Me the Money"
    Then "john@doe.com" should receive an email with the subject "Campaign donation collection complete"

    When I am on the campaign page for "Show Me the Money"
    Then I should see the following donations table
      |     Date | Amount | Collected |
      | 3/1/2016 |   $350 |     X     |
      | 3/2/2016 |   $400 |     X     |
      | 3/9/2016 |   $200 |     X     |
      |          |   $900 |           |

  Scenario: An author cancels a campaign for which there is not adequate support
