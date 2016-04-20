@wip
Feature: Admin fulfills reward
  As an administrator
  In order to keep track of what rewards have been fulfiled
  I need to be able to update the reward to reflect its completion

  Scenario: An administrator fulfills a reward
    Given there are the following house rewards
      | Description                 | Physical address required |
      | Printed copy of the book    | true                      |
      | Electronic copy of the book | false                     |

    And there is a book titled "How To Raise Money"
    And the book "How To Raise Money" has a campaign
    And the campaign for book "How To Raise Money" has the following rewards
      | Description                 | House reward                |
      | Printed copy of the book    | Printed copy of the book    |
      | Electronic copy of the book | Electronic copy of the book |
    And the campaign for the book "How To Raise Money" has received the following donations
      | Email               | Amount | Reward                      | Address                                  | Name            | State     |
      | sally@readerton.com |    100 | Printed copy of the book    | 1234 Main St, Apt 227, Dallas, TX  75200 | Sally Readerton | collected |
      | billy@bookworm.com  |    150 | Electronic copy of the book | 4321 Elm St, Dallas, TX 75201            | Billy Bookworm  | collected |
    And the campaign for the book "How To Raise Money" is collected

    And there is an administrator with email "admin@cs.com" and password "please01"
    And I am signed in as an administrator with "admin@cs.com/please01"
    And I am on the administrator home page
    Then I should see "Reward fulfillment" within the main menu

    When I click "Reward fulfillment" within the main menu
    Then I should see "Reward fulfillment" within the page title
    And I should see the following rewards table
      | Book               | Reward                      | Delivery                                              |
      | How To Raise Money | Printed copy of the book    | Sally Readerton 1234 Main St Apt 227 Dallas, TX 75200 |
      | How To Raise Money | Electronic copy of the book | billy@bookworm.com                                    |

    When I click the fulfill button within the 2nd reward row
    Then I should see "The reward has been updated successfully." within the notifications area
    And I should see the following rewards table
      | Book               | Reward                      | Delivery                                              |
      | How To Raise Money | Printed copy of the book    | Sally Readerton 1234 Main St Apt 227 Dallas, TX 75200 |
