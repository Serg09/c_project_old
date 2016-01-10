@wip
Feature: An unauthenticated user submits an inquiry
  As a user
  In order to get additional information not already present in the site
  I want to be able to submit an inquiry

  Scenario: An unauthenticated user submits an inquery
    When I am on the welcome page
    Then I should see "Contact us" within the main menu

    When I click "Contact us" within the main menu
    Then I should see "Contact us" within the page title

    When I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I fill in "Email" with "john@doe.com"
    And I fill in "How can we help?" with "What can I do about the squirrels in my attic?"
    And I click "Submit"
    Then I should see "Your inquiry has been accepted." within the notification area
    And I should see "Books" within the page title

    Then "info@crowdscribed.com" should receive an email with subject "New Inquiry"
    When "info@crowdscribed.com" opens the email
    Then they should see "What can I do about the squirrels in my attic?" in the email body
