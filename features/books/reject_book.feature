Feature: Reject a book
  As an administrator
  In order to prevent an unwanted book listing to become public
  I need to be able to reject the book

  Scenario: An administrator rejects a book
    Given there is an author named "John Doe" with email "john@doe.com" and password "please01"
    And user john@doe.com submitted a book titled "I Like Books" on 3/2/2016

    And there is an administrator with email "admin@cs.com" and password "please01"
    And I am signed in as an administrator with "admin@cs.com/please01"

    When I am on the administrator home page
    Then I should see "Books" within the main menu

    When I click "Books" within the main menu
    Then I should see "Books" within the page title
    And I should see the following books table
      | Title        | Author   | Date submitted |
      | I Like Books | John Doe |       3/2/2016 |

    When I click "I Like Books" within the books table
    Then I should see "I Like Books" within the page title

    When I click "Reject" within the admin content
    Then I should see "Books" within the page title
    And I should see "The book has been rejected successfully." within the notification area
    And "john@doe.com" should receive an email with subject "Your book has been rejected"
    When "john@doe.com" opens the email with subject "Your book has been rejected"
    Then he should see "unsubscribe" in the email body
