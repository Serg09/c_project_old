Feature: View unfulfilled rewards
  As an administrator
  In order to fulfill rewards for a successful campaign
  I need to be able to see a list of unfulfilled rewards

  Scenario: An administrator views a list of unfulfilled rewards
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
    And the campaign for the book "How To Raise Money" has received the following contributions
      | Email               | Amount | Reward                      | Address                                  | Name            | State     |
      | sally@readerton.com |    100 | Printed copy of the book    | 1234 Main St, Apt 227, Dallas, TX  75200 | Sally Readerton | collected |
      | billy@bookworm.com  |    150 | Electronic copy of the book | 4321 Elm St, Dallas, TX 75201            | Billy Bookworm  | collected |
    And the campaign for the book "How To Raise Money" is collected

    And there is a book titled "How To Spend Money"
    And the book "How To Spend Money" has a campaign
    And the campaign for book "How To Spend Money" has the following rewards
      | Description              | House reward                |
      | Printed copy of the book | Printed copy of the book    |
      | Signed T-Shirt           |                             |
    And the campaign for the book "How To Spend Money" has received the following contributions
      | Email               | Amount | Reward                      | Address                                  | Name            | State     |
      | sally@readerton.com |    75  | Signed T-Shirt              | 1234 Main St, Apt 227, Dallas, TX  75200 | Sally Readerton | collected |
      | billy@bookwork.com  |    200 | Printed copy of the book    | 4321 Elm St, Dallas, TX 75201            | Billy Bookworm  | collected |
    And the campaign for the book "How To Spend Money" is collected

    And there is a book titled "Money Stuff"
    And the book "Money Stuff" has a campaign
    And the campaign for book "Money Stuff" has the following rewards
      | Description                 | 
      | Printed copy of the book    |
    And the campaign for the book "Money Stuff" has received the following contributions
      | Email               | Amount | Reward                      | Address                       | Name           | State     |
      | billy@bookwork.com  |     50 | Printed copy of the book    | 4321 Elm St, Dallas, TX 75201 | Billy Bookworm | collected |
    And the campaign for the book "Money Stuff" is active

    And there is a book titled "More Money"
    And the book "More Money" has a campaign
    And the campaign for book "More Money" has the following rewards
      | Description                 | 
      | Printed copy of the book    |
    And the campaign for the book "More Money" has received the following contributions
      | Email               | Amount | Reward                      | Address                       | Name           | State     |
      | billy@bookwork.com  |     60 | Printed copy of the book    | 4321 Elm St, Dallas, TX 75201 | Billy Bookworm | cancelled |
    And the campaign for the book "More Money" is collected

    Given there is an administrator with email "admin@cs.com" and password "please01"
    When I am signed in as an administrator with "admin@cs.com/please01"
    And I am on the administrator home page
    Then I should see "Reward fulfillment" within the main menu

    When I click "Reward fulfillment" within the main menu
    Then I should see "Reward fulfillment" within the page title
    And I should see the following rewards table
      | Book               | Reward                      | Delivery                                              |
      | How To Raise Money | Printed copy of the book    | Sally Readerton 1234 Main St Apt 227 Dallas, TX 75200 |
      | How To Raise Money | Electronic copy of the book | billy@bookworm.com                                    |
      | How To Spend Money | Printed copy of the book    | Billy Bookworm 4321 Elm St Dallas, TX 75201           |
    

