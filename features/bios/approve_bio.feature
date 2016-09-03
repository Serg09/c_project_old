Feature: Approve a bio
  As an administrator
  In order to allow a user's bio to become public
  I need to be able to approve it

  Background:
    Given there is an author named "John Doe" with email "john@doe.com" and password "please01"
    And user john@doe.com submitted the following bio on 2/27/2015
      | Text     | I'm, like, a writer, and stuff.  |
      | Facebook | http://www.facebook.com/john_doe |
      | LinkedIn | http://www.linkedin.com/john_doe |

    And there is an administrator with email "admin@cs.com" and password "please01"
    And I am signed in as an administrator with "admin@cs.com/please01"

    When I am on the administration home page
    Then I should see "Bios" within the main menu

    When I click "Bios" within the main menu
    Then I should see "Bios" within the page title
    And I should see the following bios table
      | Author   | Date submitted |
      | John Doe |      2/27/2015 |

    When I click "John Doe" within the bios table
    Then I should see "Bio" within the page title

  Scenario: An administrator approves a pending bio
    When I click "Approve" within the admin content
    Then I should see "The bio has been approved successfully." within the notification area
    And I should see the following bios table
      | Author   | Date submitted |
    And "john@doe.com" should receive an email with subject "Bio approved!"
    When "john@doe.com" opens the email with subject "Bio approved!"
    Then he should see "unsubscribe" in the email body

  Scenario: An administrator rejects a pending bio
    When I click "Reject" within the admin content
    Then I should see "The bio has been rejected successfully." within the notification area
    And I should see the following bios table
      | Author   | Date submitted |
    And "john@doe.com" should receive an email with subject "Bio rejected"
    When "john@doe.com" opens the email with subject "Bio rejected"
    Then he should see "unsubscribe" in the email body
