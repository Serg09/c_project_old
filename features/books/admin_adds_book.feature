@wip
Feature: Add a book administratively
  As an administrator
  In order to information available for a book for which the author does not have a user account
  I need to be able to add the book

  Scenario: An administrator adds a book
    Given there is an author named "George Orwell"
    And author "George Orwell" has a bio
    And the following genres are available
      | Name            |
      | Children's      |
      | Poetry          |
      | Science Fiction |
      | Drama           |
    And there is an administrator with email "joe@admin.com" and password "please01"

    When I am signed in as an administrator with "joe@admin.com/please01"
    And I am on the administration home page
    Then I should see "Authors" within the main menu

    When I click "Authors" within the main menu
    Then I should see "Authors" within the page title
    And I should see the following authors table
      | Last name | First name |
      | Orwell    | George     |

    When I click the books button within the 1st author row
    Then I should see "Books for George Orwell" within the page title

    When I click "Add" within the administration content
    Then I should see "New book for George Orwell" within the page title

    When I fill in "Title" with "1984"
    And I fill in "Short description" with "This is a book"
    And I fill in "Long description" with "This is a book about some stuff"
    And I check "Drama" and "Science Fiction" within the genre list
    And I select file "book_cover.jpg" for "Cover image"
    And I select file "sample.pdf" for "Sample"
    And I click "Save"
    Then I should see "The book was created successfully" within the notification area
    And I should see "Books for George Orwell" within the page title
    And I should see the following books table
      | Title |
      | 1984  |

