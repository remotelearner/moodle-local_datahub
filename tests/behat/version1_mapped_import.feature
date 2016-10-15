@local @local_datahub @javascript

Feature: Import a version1 file with column mappings.

    Background:
        Given I log in as "admin"


    # T33.2x
    Scenario: version1 mapped user import succeeds.
        Given the following Moodle user profile fields exist:
          | category |  name | type | default | options |
          | Other fields | customtext1 | text | Custom 1 default | |
          | Other fields | custommenu1 | menu | Option C | Option A,Option B,Option C,Option D |
        And I map the following fields for "version1" "user" import:
          | field | column |
          | username | User Name |
          | idnumber | MyID |
          | profile_field_customtext1 | Custom text 1 |
          | profile_field_custommenu1 | Custom menu 1 |
        And I make a Datahub "version1" manual "user" import with file "version1_mapped_user.csv"
        Then I should see "All lines from import file version1_mapped_user.csv were successfully processed. (1 of 1)"
        And a "user" record with '{"idnumber":"testuser","username":"testuser","firstname":"Test","lastname":"User","city":"testcity","country":"CA"}' "should" exist
        # TBD: verify custom profile fields set.

    # T33.2x
    Scenario: version1 mapped course import succeeds.
        Given I map the following fields for "version1" "course" import:
          | field | column |
          | shortname | Short Name |
          | fullname | Full Name |
        And I make a Datahub "version1" manual "course" import with file "version1_mapped_course.csv"
        Then I should see "All lines from import file version1_mapped_course.csv were successfully processed. (1 of 1)"
        And a "course" record with '{"shortname":"testcourse2","fullname":"testcourse2"}' "should" exist

    # T33.2x
    Scenario: version1 mapped enrolment import succeeds.
        Given the following "users" exist:
          | username | firstname | lastname | email |
          | testuser | Test | User | testuser@email.com |
        And the following "courses" exist:
          | fullname | shortname | format |
          | Test Cousre 2 | testcourse2 | topics |
        And I map the following fields for "version1" "enrolment" import:
          | field | column |
          | action | act |
          | username | User Name |
          | context | ctx |
          | instance | inst |
        And I make a Datahub "version1" manual "enrolment" import with file "version1_mapped_enrolment.csv"
        Then I should see "All lines from import file version1_mapped_enrolment.csv were successfully processed. (1 of 1)"
        And the following enrolments should exist:
           | course | user |
           | testcourse2 | testuser |

