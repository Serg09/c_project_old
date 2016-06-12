Feature: Make a donation
  As a user
  In order to support a book project I want to see completed
  I want to be able to donate money to the project

  Background:
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has an approved book titled "Great Stuff To Know"
    And author john@doe.com has an approved bio
    And book "Great Stuff To Know" has an active campaign
    And the campaign for book "Great Stuff To Know" has the following rewards
      | Description     | Minimum donation | Physical address required |
      | Signed copy     |               20 | true                      |
      | Electronic copy |               15 | false                     |

    When I am on the welcome page
    Then I should see "Books" within the main menu

    When I click "Books" within the main menu
    Then I should see "Books" within the page title
    And I should see "Great Stuff To Know" within the main content

    When I click "Great Stuff To Know" within the main content
    Then I should see "Great Stuff To Know" within the book title

    When I click "Contribute!"
    Then I should see "Make a donation!" within the page title

  Scenario: A user donates using a credit card
    When I fill in "Amount" with "50"
    And I fill in "Credit card" with "4444111144441111"
    And I select "VISA" from "Type"
    And I select "5" from "Expiration month"
    And I select "2020" from "Expiration year"
    And I fill in "CVV" with "123"
    And I fill in "First name" with "Sally"
    And I fill in "Last name" with "Readerton"
    And I fill in "Address" with "1234 Main St"
    And I fill in "Line 2" with "Apt 227"
    And I fill in "City" with "Bookville"
    And I fill in "State" with "TX"
    And I fill in "Postal code" with "75123"
    And I fill in "Email" with "sally.readerton@mymail.com" within the main content
    And I click "Submit"
    Then I should see "Book" within the page title
    And I should see "Your donation has been saved successfully. Expect to receive a confirmation email with all of the details." within the notification area
    And "sally.readerton@mymail.com" should receive an email with subject "Donation receipt"
    And "info@crowdscribed.com" should receive an email with subject "Donation Received!"
    And "john@doe.com" should receive an email with subject "Donation Received!"

    When "john@doe.com" opens the email with subject "Donation Received!"
    Then he should see "unsubscribe" in the email body

  Scenario: A user donates using a predefined amount + reward option
    When I select the "Signed copy" option
    And I fill in "Credit card" with "4444111144441111"
    And I select "VISA" from "Type"
    And I select "5" from "Expiration month"
    And I select "2020" from "Expiration year"
    And I fill in "CVV" with "123"
    And I fill in "First name" with "Sally"
    And I fill in "Last name" with "Readerton"
    And I fill in "Address" with "1234 Main St"
    And I fill in "Line 2" with "Apt 227"
    And I fill in "City" with "Bookville"
    And I fill in "State" with "TX"
    And I fill in "Postal code" with "75123"
    And I fill in "Email" with "sally.readerton@mymail.com" within the main content
    And I click "Submit"
    Then I should see "Book" within the page title
    And I should see "Your donation has been saved successfully. Expect to receive a confirmation email with all of the details." within the notification area
    And "sally.readerton@mymail.com" should receive an email with subject "Donation receipt"
    And "john@doe.com" should receive an email with subject "Donation Received!"
    And "info@crowdscribed.com" should receive an email with subject "Donation Received!"
