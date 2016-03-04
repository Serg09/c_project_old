Feature: Add a book
  As an author
  In order to acquire readers for my book
  I want to be able to create a page for it on the site

  Background:
    Given there is an author with email address "john@doe.com" and password "please01"
    And I am signed in as an author with "john@doe.com/please01"
    And the following genres are available
      | Name            |
      | Children's      |
      | Poetry          |
      | Science Fiction |
      | Drama           |

    When I am on the author home page
    Then I should see "My books" within the main menu

    When I click "My books" within the main menu
    Then I should see "My books" within the page title

    When I click "Add" within the main content
    Then I should see "New book" within the page title

  Scenario: An author creates a book
    When I fill in "Title" with "Green Eggs and Ham"
    And I fill in "Short description" with "Sam I Am does not like green eggs and ham."
    And I fill in "Long description" with "Blah blah blah blah"
    And I check "Children's" and "Poetry" within the genre list
    And I select file "book_cover.jpg" for "Cover image"
    And I select file "sample.pdf" for "Sample"
    And I click "Submit"

    Then I should see "Your book has been submitted successfully." within the notification area
    And I should see "This book is under review. We will review it as soon as we can." within the main content
    And "info@crowdscribed.com" should receive an email with subject "New book submission"

  Scenario: An author tries to create a book supplying the wrong file type for the sample
    When I fill in "Title" with "Green Eggs and Ham"
    And I fill in "Short description" with "Sam I Am does not like green eggs and ham."
    And I fill in "Long description" with "Blah blah blah blah"
    And I check "Children's" and "Poetry" within the genre list
    And I select file "book_cover.jpg" for "Cover image"
    And I select file "book_cover.jpg" for "Sample"
    And I click "Submit"

    Then I should see "New book" within the page title
    And I should see "Sample file must be a PDF" within the main content

  Scenario: An author tries to create a book supplying the wrong file type for the cover image
    When I fill in "Title" with "Green Eggs and Ham"
    And I fill in "Short description" with "Sam I Am does not like green eggs and ham."
    And I fill in "Long description" with "Blah blah blah blah"
    And I check "Children's" and "Poetry" within the genre list
    And I select file "sample.pdf" for "Cover image"
    And I select file "sample.pdf" for "Sample"
    And I click "Submit"

    Then I should see "New book" within the page title
    And I should see "Cover image file must be an image" within the main content
