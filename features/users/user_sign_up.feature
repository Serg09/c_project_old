Feature: An user signs up
  As an unauthenticated user
  In order to use the services offered by the site
  I need to be able to create an user account

  Scenario: A user signs up successfully
    When I am on the welcome page
    Then I should see "Signup" within the main menu

    When I click "Signup" within the main menu
    Then I should see "Signup" within the page title

    When I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I fill in "Email" with "john@doe.com" within the main content
    And I select "Starter (Free)" from "Which package would you like?"
    And I fill in "Phone number" with "214-555-0000"
    And I check "It is OK if my advisor contacts me by phone"
    And I fill in "Username" with "jdoe"
    And I fill in "Password" with "please01" within the main content
    And I fill in "Password confirmation" with "please01"
    And I click "Sign up"

    Then I should see "A message with a confirmation link has been sent to your email address." within the notification area
    And "john@doe.com" should receive an email with subject "Confirmation instructions"

    When I open the email with subject "Confirmation instructions"
    And I click the first link in the email
    Then I should see "Your email address has been successfully confirmed." within the notification area
    And "info@crowdscribed.com" should receive an email with subject "New user"
