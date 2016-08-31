Feature: View a list of authors
  As a user
  In order to see who is writing books I might want to read
  I want to be able to see a list of authors

  Scenario: A user views the list of authors
    Given there is an author named "John Doe"
    And there is an author named "Robin Banks"
    And there is an author named "Michael Hunt"
    And there is a user named "Jane Doe"

    When I am on the welcome page
    Then I should see "Browse authors" within the main menu

    When I click "Browse authors" within the main menu
    Then I should see "Authors" within the page title
    And I should see the following author records
      | First name | Last name |
      | Robin      | Banks     |
      | John       | Doe       |
      | Michael    | Hunt      |
