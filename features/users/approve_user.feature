Feature: Approve a user
  As an administrator
  In order to control who has access to certain parts of the site
  I need to be able to approve a request for an user account

  Scenario: An administrator approves an user request
    Given there is an administrator with email "admin@cs.com" and password "please01"
    And there is a pending user named "John Doe" with email "john@doe.com" submitted on 1/17/2016
    And I am signed in as an administrator with "admin@cs.com/please01"

    When I am on the administration home page
    Then I should see "Users" within the main menu

    When I click "Users" within the main menu
    Then I should see "Users" within the page title
    And I should see the following users table
      |          Signup date | Name     | Email        |
      |   1/17/2016 12:00 AM | John Doe | john@doe.com |

    When I click "John Doe" within the users table
    Then I should see "User" within the page title
    When I click "Approve"
    Then I should see "The user has been approved successfully." within the notification area
    And I should see "Users" within the page title
    And I should see the following users table
      | Signup date | Name     | Email        |
