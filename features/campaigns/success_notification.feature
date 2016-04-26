@wip
Feature: Success notifications
  As an author
  In order to know that my campaign has reached its goal
  I want to receive a notification when it happens

  Background:
    Given there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has a book titled "Tell Me When"
    And the book "Tell Me When" has a campaign targeting $500

  Scenario: An author receives a notification when the campaign reaches its goal
    When a user donates $251 for the book "Tell Me When"
    Then "john@doe.com" should receive no email with subject "Your campaign for Tell Me When has reached its goal!"

    When a user donates $249 for the book "Tell Me When"
    When a user donates $1 for the book "Tell Me When"
    Then "john@doe.com" should receive an email with subject "Your campaign for Tell Me When has reached its goal!"
    And "info@crowdscribed.com" should receive an email with subject "The campaign for Tell Me When has reached its goal!"

  Scenario: An author does not receive additional notifications after receiving the first one
    Given notification has been sent for the success of the campaign for the book "Tell Me When"
    When a user donates $502 for the book "Tell Me When"
    Then "john@doe.com" should receive no email with subject "Your campaign for Tell Me When has reached its goal!"
