Feature: Submit a biography
  As an author
  In order to inform readers about my history
  I need to be able to write a biography for myself.

  Scenario: An author submits a biography
    Given there is an author with email "john@doe.com" and password "please01"
    And I am signed in as an author with "john@doe.com/please01"

    When I am on the author home page
    Then I should see "Bio" within the main menu

    When I click "Bio" within the main menu
    Then I should see "New bio" within the page title

    When I fill in "Text" with "I sure have been writing words for a long time now. I'm starting to get pretty good at it, too."
    And I select file "author_photo.jpg" for "Photo"
    And I fill in "YouTube" with "https://www.youtube.com/watch?v=JvkbFc-th28"
    And I fill in "Facebook" with "https://www.facebook.com/JasonMraz/"
    And I fill in "Twitter" with "https://twitter.com/jason_mraz"
    And I fill in "Instagram" with "https://www.instagram.com/jason_mraz/?hl=en"
    And I fill in "Tumblr" with "http://jasonmraz.tumblr.com/"
    And I fill in "LinkedIn" with "https://www.linkedin.com/in/jasonmraz"
    And I click "Submit"
    Then I should see "Your bio has been submitted successfully." within the notification area
    And I should see "This bio is under review. We will review it as soon as we can." within the main content
    And "info@crowdscribed.com" should receive an email with subject "New bio submission"

    When an administrator has approved the bio for author john@doe.com
    And I am on the author home page
    When I click "Bio" within the main menu
    Then I should see "I sure have been writing words for a long time" within the main content
