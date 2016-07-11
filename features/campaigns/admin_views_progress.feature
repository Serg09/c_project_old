Feature: Administrator views campaign progress
  As an administrator
  In order to monitor active campaigns
  I need to be able to see their progress

  Scenario: An administrator views the progress of a campaign
    Given today is 3/2/2016
    And there is an author named "John Doe" with email address "john@doe.com"
    And author john@doe.com has a book titled "Some Words of Mine"
    And book "Some Words of Mine" has a campaign targeting $1,000 by 4/30/2016
    And the campaign for the book "Some Words of Mine" has received the following contributions
      | Email              | Amount |      Date |
      | some@reader.com    |    125 | 2/29/2016 |
      | another@person.com |     50 |  3/1/2016 |
    And there is an administrator with email "joe@admin.com" and password "please01"
    And I am signed in as an administrator with "joe@admin.com/please01"

    When I am on the administration home page
    Then I should see "Campaigns" within the main menu

    When I click "Campaigns" within the main menu
    Then I should see "Campaigns" within the page title
    And I should see the following campaigns table
      | Author   | Title              | Target date |
      | John Doe | Some Words of Mine |   4/30/2016 |

    When I click the campaign progress button within the 1st campaign row
    Then I should see "Campaign for Some Words of Mine" within the page title
    And I should see the following campaign progress table
      | Goal                    | $1,000 |
      | Contributions           |      2 |
      | Raised                  |   $175 |
      | Est. reward fulfillment |     $0 |
      | Est. payment fees       |     $0 |
      | Est. available          |   $175 |
      | Still seeking           |   $825 |
      | Days remaining          |     59 |

    And I should see the following contributions table
      | Contributor        |      Date | Amount |
      | some@reader.com    | 2/29/2016 |   $125 |
      | another@person.com |  3/1/2016 |    $50 |
