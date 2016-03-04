Feature: Resolve an inquiry
  As an administrator
  In order to track communication with customers
  I need to be able to mark an inquiry as resolved

  Scenario: An administrator resolves an inquiry
    Given there is an administrator with email "admin@cs.com" and password "please01"
    And user "John Doe" with email "john@doe.com" has submitted an inquiry asking "How much for the dog?" at 3:42 PM on 2/27/2016

    When I am signed in as an administrator with "admin@cs.com/please01"
    Then I should see "Inquiries" within the main menu

    When I click "Inquiries" within the main menu
    Then I should see "Inquiries" within the page title
    And I should see the following inquiries table
     | Name     | Email        |          Received |
     | John Doe | john@doe.com | 2/27/2016 3:42 PM |

    When I click "John Doe" within the inquiries table
    Then I should see "Inquiry" within the page title
    And I should see "How much for the dog?" within the admin content

    When I click "Archive" within the admin content
    Then I should see "The inquiry has been archived successfully" within the notification area
    And I should see the following inquiries table
     | Name     | Email        |          Received |
