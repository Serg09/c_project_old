@wip
Feature: Edit a book
  As an author
  In order to correct misinformation in a book
  I need to be able to update it

  Scenario: An author updates a book
    Given there is an author with email address "john@doe.com" and password "please01"
    And author john@doe.com has an approved book titled "My Book Aboat Me"
    And I am signed in as an author with "john@doe.com/please01"

    When I am on the author home page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title
    And I should see the following books table
      | Title            |
      | My Book Aboat Me |

    When I click "Edit" within the 1st book row
    Then I should see "Edit book" within the page title

    When I fill in "Title" with "My Book About Me"
    And I click "Submit"

    Then I should see "Book" within the page title
    And I should see "The book was updated successfully." within the notification area
    And "info@crowdscribed.com" should receive an email with subject "Book edit submission"
