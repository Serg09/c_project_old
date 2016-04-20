@wip
Feature: Author fulfills reward
  As an author
  In order to keep track of which rewards have been fulfilled
  I need to be able to update the reward to reflect its completion

  Scenario: An author fulfills a reward
    Given there are the following house rewards
      | Description                 | Physical address required |
      | Printed copy of the book    | true                      |
      | Electronic copy of the book | false                     |

    And there is an author with email "john@doe.com" and password "please01"
    And author john@doe.com has a book titled "How To Raise Money"
    And the book "How To Raise Money" has a campaign
    And the campaign for book "How To Raise Money" has the following rewards
      | Description                 | House reward                | Physical address required |
      | Signed copy of the book     |                             | true                      |
      | Electronic copy of the book | Electronic copy of the book |                           |
    And the campaign for the book "How To Raise Money" has received the following donations
      | Email               | Amount | Reward                      | Address                                  | Name            | State     |
      | sally@readerton.com |    100 | Signed copy of the book     | 1234 Main St, Apt 227, Dallas, TX  75200 | Sally Readerton | collected |
      | billy@bookworm.com  |    150 | Electronic copy of the book | 4321 Elm St, Dallas, TX 75201            | Billy Bookworm  | collected |
    And the campaign for the book "How To Raise Money" is collected

    And I am signed in as an author with "john@doe.com/please01"

    When I am on the author home page
    Then I should see "Reward fulfillment" within the main menu

    When I click "Reward fulfillment" within the main menu
    Then I should see "Reward fulfillment" within the page title
    And I should see the following rewards table
      | Book               | Reward                     | Delivery                                              |
      | How To Raise Money | Signed copy of the book    | Sally Readerton 1234 Main St Apt 227 Dallas, TX 75200 |

    When I click the fulfill button within the 1st reward row
    Then I should see "The reward was updated successfully" within the notifications area
    And I should see the following rewards table
      | Book               | Reward                     | Delivery                                              |
