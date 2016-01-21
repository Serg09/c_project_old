Feature: Approve an author
  As an administrator
  In order to control who has access to certain parts of the site
  I need to be able to approve a request for an author account

  Scenario: An administrator approves an author request
    Given there is an administrator with email "admin@cs.com" and password "please01"
    And there is a pending author named "John Doe" with email "john@doe.com" submitted on 1/17/2016
    And I am signed in as an administrator with "admin@cs.com/please01"

    When I am on the administration home page
    Then I should see "Authors" within the main menu

    When I click "Authors" within the main menu
    Then I should see "Authors" within the page title
    And I should see the following authors table
      |          Signup date | Name     | Email        |
      |   1/17/2016 12:00 AM | John Doe | john@doe.com |

    When I click "John Doe" within the authors table
    Then I should see "Author" within the page title
    When I click "Accept"
    Then I should see "The author has been accepted successfully." within the notification area
    And I should see "Authors" within the page title
    And I should see the following authors table
      | Signup date | Name     | Email        |
