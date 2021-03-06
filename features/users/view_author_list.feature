Feature: View a list of authors
  As a user
  In order to see who is writing books I might want to read
  I want to be able to see a list of authors

  Scenario: A user views the list of authors
    Given there is an author named "John Doe" with email address "john@doe.com"
    And there is an author named "Robin Banks" with email address "robin@banks.com"
    And there is an author named "Michael Hunt" with email address "michael@hunt.com"
    And there is a user named "Jane Doe"
    And there is an author named "Pat Conroy"
    And author "Pat Conroy" has a bio

    When I am on the welcome page
    Then I should see "Browse authors" within the main menu

    When I click "Browse authors" within the main menu
    Then I should see "Authors" within the page title
    And I should see the following author records
      | First name | Last name |
      | Robin      | Banks     |
      | Pat        | Conroy    |
      | John       | Doe       |
      | Michael    | Hunt      |
