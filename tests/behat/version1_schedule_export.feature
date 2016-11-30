@local @local_datahub @javascript

Feature: version1 export.

    Background:
        Given I log in as "admin"


    # T33.15.1 ~ 2b
    Scenario: version1 basic/period schedule incremental export succeeds.
        Given the following "users" exist:
          | username | firstname | lastname | email |
          | testuser | Test | User | testuser@email.com |
          | testuser2 | Test | User2 | testuser2@email.com |
        And the following "courses" exist:
          | fullname | shortname | format |
          | Test Cousre 1 | testcourse1 | topics |
          | Test Cousre 2 | testcourse2 | topics |
          | Test Cousre 3 | testcourse3 | topics |
        And the following "grade categories" exist:
          | fullname | course |
          | Grade Cat1 | testcourse1 |
          | Grade Cat2 | testcourse2 |
          | Grade Cat3 | testcourse3 |
        And the following "grade items" exist:
          | itemname | course | gradecategory |
          | gradeitem1 | testcourse1 | Grade Cat1 }
          | gradeitem2 | testcourse2 | Grade Cat2 |
          | gradeitem3 | testcourse3 | Grade Cat3 |
        And the following "course enrolments" exist:
          | user | course | role |
          | testuser | testcourse1 | student |
          | testuser2 | testcourse2 | student |
          | testuser | testcourse3 | student |
        And I visit Moodle course "testcourse1"
        And I navigate to "Grades" node in "Course administration"
        And I turn editing mode on
        And I give the grade "85.76" to the user "Test User" for the grade item "gradeitem1"
        And I give the grade "85.76" to the user "Test User" for the grade item "Course total"
        And I click on "Save changes" "button"
        And I visit Moodle course "testcourse2"
        And I navigate to "Grades" node in "Course administration"
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
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Grade,Letter |
          | Test,User,testuser,testuser,testcourse1,.*,.*,85.76000,B |
          | Test,User2,testuser2,testuser2,testcourse2,.*,.*,76.89000,C |
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "30" seconds
        # Add new class completions
        And I visit Moodle course "testcourse3"
        And I navigate to "Grades" node in "Course administration"
        And I turn editing mode on
        And I give the grade "98.25" to the user "Test User" for the grade item "gradeitem3"
        And I give the grade "98.25" to the user "Test User" for the grade item "Course total"
        And I click on "Save changes" "button"
        And I update the timemodified for:
          | gradeitem |
          | gradeitem3 |
          | testcourse3 |
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "version1" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Grade,Letter |
          | Test,User,testuser,testuser,testcourse3,.*,.*,98.25000,A |
        And the Datahub "version1" export file "should not" contain lines:
          | line |
          | Test,User,testuser,testuser,testcourse1,.*,.*,85.76000,B |
          | Test,User2,testuser2,testuser2,testcourse2,.*,.*,76.89000,C |

    # T33.15.2 ~ 3b
    Scenario: version1 advanced schedule non-incremenatal export succeeds.
        Given the following "users" exist:
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
          | gradeitem1 | testcourse1 | Grade Cat1 }
          | gradeitem2 | testcourse2 | Grade Cat2 |
        And the following "course enrolments" exist:
          | user | course | role |
          | testuser | testcourse1 | student |
          | testuser2 | testcourse2 | student |
        And I visit Moodle course "testcourse1"
        And I navigate to "Grades" node in "Course administration"
        And I turn editing mode on
        And I give the grade "95.76" to the user "Test User" for the grade item "gradeitem1"
        And I give the grade "95.76" to the user "Test User" for the grade item "Course total"
        And I click on "Save changes" "button"
        And I visit Moodle course "testcourse2"
        And I navigate to "Grades" node in "Course administration"
        And I turn editing mode on
        And I give the grade "16.89" to the user "Test User2" for the grade item "gradeitem2"
        And I give the grade "16.89" to the user "Test User2" for the grade item "Course total"
        And I click on "Save changes" "button"
        And the following config values are set as admin:
          | nonincremental | 1 | dhexport_version1 |
        And the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh2c | dhexport_version1 | advanced | {"runs":3,"frequency":5,"units":"minute"} |
        Then a "local_datahub_schedule" record with '{"plugin":"dhexport_version1"}' "should" exist
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "export_version1_scheduled_" log file should contain "Export file .*csv successfully created"
        And the Datahub "version1" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Grade,Letter |
          | Test,User,testuser,testuser,testcourse1,.*,.*,95.76000,A |
          | Test,User2,testuser2,testuser2,testcourse2,.*,.*,16.89000,F |
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "version1" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Grade,Letter |
          | Test,User,testuser,testuser,testcourse1,.*,.*,95.76000,A |
          | Test,User2,testuser2,testuser2,testcourse2,.*,.*,16.89000,F |

    # T33.15.2 ~
    Scenario: version1 advanced calendar schedule export succeeds.
        Given the following "users" exist:
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
          | gradeitem1 | testcourse1 | Grade Cat1 }
          | gradeitem2 | testcourse2 | Grade Cat2 |
        And the following "course enrolments" exist:
          | user | course | role |
          | testuser | testcourse1 | student |
          | testuser2 | testcourse2 | student |
        And I visit Moodle course "testcourse1"
        And I navigate to "Grades" node in "Course administration"
        And I turn editing mode on
        And I give the grade "45.76" to the user "Test User" for the grade item "gradeitem1"
        And I give the grade "45.76" to the user "Test User" for the grade item "Course total"
        And I click on "Save changes" "button"
        And I visit Moodle course "testcourse2"
        And I navigate to "Grades" node in "Course administration"
        And I turn editing mode on
        And I give the grade "56.89" to the user "Test User2" for the grade item "gradeitem2"
        And I give the grade "56.89" to the user "Test User2" for the grade item "Course total"
        And I click on "Save changes" "button"
        And the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh3b | dhexport_version1 | advanced | {"startdate":"-3 days +5 minutes","recurrence":"calendar",enddate:"+2 days","weekdays":"1,2,3,4,5,6,7","months":"this"} |
        Then a "local_datahub_schedule" record with '{"plugin":"dhexport_version1"}' "should" exist
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "export_version1_scheduled_" log file should contain "Export file .* successfully created"
        And the Datahub "version1" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Grade,Letter |
          | Test,User,testuser,testuser,testcourse1,.*,.*,45.76000,F |
          | Test,User2,testuser2,testuser2,testcourse2,.*,.*,56.89000,F |

