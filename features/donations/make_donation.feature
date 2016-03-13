@wip
Feature: Make a donation
  As a user
  In order to support a book project I want to see completed
  I want to be able to donate money to the project

  Scenario: A user donates using a credit card
    Given today is 3/2/2016
    And there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has an approved book titled "Great Stuff To Know"
    And author john@doe.com has an approved bio
    And book "Great Stuff To Know" has an active campaign

    When I am on the welcome page
    Then I should see "Books" within the main menu

    When I click "Books" within the main menu
    Then I should see "Books" within the page title
    And I should see "Great Stuff To Know" within the main content

    When I click "Great Stuff To Know" within the main content
    Then I should see "Great Stuff To Know" within the book title

    When I click "Donate!"
    Then I should see "Make a donation!" within the page title

    When I fill in "Credit card" with "4444111144441111"
    And I select "visa" from "Credit card type"
    And I fill in "Expiration month" with "5"
    And I fill in "Expiration year" with "2020"
    And I fill in "CVV" with "123"
    And I fill in "First name" with "Sally"
    And I fill in "Last name" with "Readerton"
    And I fill in "Address" with "1234 Main St"
    And I fill in "Address cont." with "Apt 227"
    And I fill in "City" with "Bookville"
    And I fill in "State" with "TX"
    And I fill in "Postal code" with "75123"
    And I fill in "Amount" with "50"
    And I click "Submit"
    Then I should see "Thank you!" within the page header
    And I should see "Your payment has been saved successfully." within the notification area
    And I should see "Your donation is appreciated! Your card will not be charged until the campaign has reached its goal. If the campaign fails to reach its goal, you will not be charged." within the main content
