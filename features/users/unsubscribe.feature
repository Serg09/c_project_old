Feature: Unsubscribe from emails
  As a user
  In order to avoid a cluttered inbox
  I want to be able to unsubscribed from automated emails

  Scenario: A user unsubscribes using the link in an email
    Given there is a user with email address "john@doe.com" and password "please01"

    When the mailer sends a campaign progress notification email to user john@doe.com
    Then "john@doe.com" should receive an email with subject /^Campaign progress/

    When I open the email with subject /^Campaign progress/
    Then I should see "unsubscribe" in the email body

    When I click the first link in the email
    Then I should see "You have been unsubscribed" within the notification area
    And I should see "You may change your email preferences at any time by signing in and updating your profile" within the main content
