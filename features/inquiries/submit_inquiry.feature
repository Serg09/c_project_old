Feature: An unauthenticated user submits an inquiry
  As a user
  In order to get additional information not already present in the site
  I want to be able to submit an inquiry

  Scenario: An unauthenticated user submits an inquiry
    When I am on the welcome page
    Then I should see "Contact us" within the main menu

    When I click "Contact us" within the main menu
    Then I should see "Contact us" within the page title

    When I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I fill in "Email" with "john@doe.com" within the main content
    And I fill in "How can we help?" with "What can I do about the squirrels in my attic?"
    And I click "Submit"
    Then I should see "Your inquiry has been accepted." within the notification area
    And I should see "Books" within the page title

    Then "info@crowdscribed.com" should receive an email with subject /\ACrowdscribe inquiry \d{6}\z/
    When "info@crowdscribed.com" opens the email
    Then they should see "What can I do about the squirrels in my attic?" in the email body

  Scenario: An unauthenticated user tries to submit a inquiry without supplying an email
    When I am on the welcome page
    Then I should see "Contact us" within the main menu

    When I click "Contact us" within the main menu
    Then I should see "Contact us" within the page title

    When I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I fill in "How can we help?" with "What can I do about the squirrels in my attic?"
    And I click "Submit"
    Then I should see "We were unable to accept your inquiry." within the notification area
    And I should see "Contact us" within the page title
    And I should see "Email can't be blank" within the main content

    Then "info@crowdscribed.com" should not receive any emails
