@local @local_datahub @javascript

Feature: version1 export field mapping

    Background:
        Given I log in as "admin"


    # T33.25
    Scenario: version1 basic/period schedule incremental export with field mappings.
        Given the following Moodle user profile fields exist:
          | category |  name | type | default | options |
          | Other fields | customtext1 | text | Custom 1 default | |
          | Other fields | custommenu1 | menu | Option C | Option A,Option B,Option C,Option D |
        And I add the following fields for version1 export:
          | field | export |
          | customtext1 | Custom text 1 |
          | custommenu1 | Custom menu 1 |
        And the following "users" exist:
          | username | firstname | lastname | email |
          | testuser | Test | User | testuser@email.com |
          | testuser2 | Test | User2 | testuser2@email.com |
        And the following "courses" exist:
          | fullname | shortname | format |
          | Test Cousre 1 | testcourse1 | topics |
          | Test Cousre 2 | testcourse2 | topics |
        And the following "grade categories" exist:
          | fullname | course |
          | Grade Cat1 | testcourse1 |
          | Grade Cat2 | testcourse2 |
        And the following "grade items" exist:
          | itemname | course | gradecategory |
          | gradeitem1 | testcourse1 | Grade Cat1 |
          | gradeitem2 | testcourse2 | Grade Cat2 |
        And the following "course enrolments" exist:
          | user | course | role |
          | testuser | testcourse1 | student |
          | testuser2 | testcourse2 | student |
        And I visit Moodle course "testcourse1"
        And I click on "Grades" "text" in the "#nav-drawer" "css_element"
        And I turn editing mode on
        And I give the grade "85.76" to the user "Test User" for the grade item "gradeitem1"
        And I give the grade "85.76" to the user "Test User" for the grade item "Course total"
        And I click on "Save changes" "button"
        And I visit Moodle course "testcourse2"
        And I click on "Grades" "text" in the "#nav-drawer" "css_element"
        And I turn editing mode on
        And I give the grade "76.89" to the user "Test User2" for the grade item "gradeitem2"
        And I give the grade "76.89" to the user "Test User2" for the grade item "Course total"
        And I click on "Save changes" "button"
        And  the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh1b | dhexport_version1 | period | 5m |
        Then a "local_datahub_schedule" record with '{"plugin":"dhexport_version1"}' "should" exist
        And I wait "0" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "export_version1_scheduled_" log file should contain "Export file .* successfully created"
        And the Datahub "version1" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Grade,Letter,customtext1,"Custom menu 1" |
          | Test,User,testuser,,testcourse1,.*,.*,85.76000,B,"Custom 1 default","Option C" |
          | Test,User2,testuser2,,testcourse2,.*,.*,76.89000,C,"Custom 1 default","Option C" |
       # NOTE: the heading column customtext1 should really be "Custom text 1", above ^

