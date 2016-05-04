@wip
Feature: Resubscribe
  As a user
  In order to start getting emails again that I had previously discontinued
  I need to be able to resubscribe

  Scenario: A user resubscribes to emails
    Given there is a user with email address "john@doe.com" and password "please01"
    And user john@doe.com is unsubscribed
    And I am signed in as a user with "john@doe.com/please01"

    When I am on the user home page
    Then I should see "Profile" within the main menu

    When I click "Profile" within the main menu
    Then I should see "Profile" within the page title

    When I check "I want to receive emails from Crowdscribed"
    And I click "Save"

    Then I should see "Your profile was updated successfully" within the notification area
