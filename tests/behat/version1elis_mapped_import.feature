@local @local_datahub @javascript @dhimport_version1elis
Feature: Import a version1elis file with column mappings.

    Background:
        Given I log in as "admin"


    # T37.?a
    Scenario: version1elis mapped user import succeeds.
        Given the following ELIS custom fields exist:
          | category | name | contextlevel | datatype | control | multi | options | default |
          | cat1 | customuser1 | user | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I map the following fields for "version1elis" "user" import:
          | field | column |
          | action | act |
          | username | User Name |
          | idnumber | MyID |
          | customuser1 | Custom User 1 |
        And I make a Datahub "version1elis" manual "user" import with file "version1elis_mapped_user.csv"
        Then I should see "All lines from import file version1elis_mapped_user.csv were successfully processed. (1 of 1)"
        And the Datahub "import_version1elis_manual_user_" log file should contain '\[version1elis_mapped_user.csv line 2\] User with username "testusername", email "test@user.com", idnumber "testidnumber" successfully created.'
        And a "local_elisprogram_usr" record with '{"idnumber":"testidnumber","username":"testusername","firstname":"testfirstname","lastname":"testlastname","country":"CA"}' "should" exist
        And a "user" record with '{"idnumber":"testidnumber","username":"testusername","firstname":"testfirstname","lastname":"testlastname","country":"CA"}' "should" exist

    # T37.?b
    Scenario: version1elis mapped course imports succeeds.
        Given the following ELIS custom fields exist:
          | category | name | contextlevel | datatype | control | multi | options | default |
          | cat1 | customcourse1 | course | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I map the following fields for "version1elis" "course" import:
          | field | column |
          | action | act |
          | context | ctx |
          | idnumber | MyID |
          | name | Course Name |
          | customcourse1 | Custom Course 1 |
        And I make a Datahub "version1elis" manual "course" import with file "version1elis_mapped_course.csv"
        Then I should see "All lines from import file version1elis_mapped_course.csv were successfully processed. (1 of 1)"
        And the Datahub "import_version1elis_manual_course_" log file should contain '\[version1elis_mapped_course.csv line 2\] Course description with idnumber "testcourseid" successfully created.'
        And a "local_elisprogram_crs" record with '{"idnumber":"testcourseid","name":"testcourse"}' "should" exist


