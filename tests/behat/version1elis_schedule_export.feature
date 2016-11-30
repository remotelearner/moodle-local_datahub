@local @local_datahub @javascript

Feature: version1elis scheduled export.

    Background:
        Given I log in as "admin"
        And the following ELIS users exist:
          | username | idnumber |
          | testuser | testuser |
          | testuser2 | testuser2 |
        And the following ELIS courses exist:
          | name | idnumber | credits | completion_grade |
          | Test Cousre 1 | testcourse1 | 1.2 | 51.25 |
          | Test Cousre 2 | testcourse2 | 2.4 | 52.5 |
        And the following ELIS classes exist:
          | idnumber | course_idnumber |
          | testclass1 | testcourse1 |
          | testclass2 | testcourse2 |


    # T33.15.1 ~ 2c
    Scenario: version1elis basic/period schedule incremental export succeeds.
        Given the following ELIS courses exist:
          | name | idnumber | credits | completion_grade |
          | Test Cousre 3 | testcourse3 | 3.6 | 53.75 |
        And the following ELIS classes exist:
          | idnumber | course_idnumber |
          | testclass3 | testcourse3 |
        And the following ELIS class enrolments exist:
          | user_idnumber | class_idnumber | completestatus | grade | credits | locked |
          | testuser | testclass1 | passed | 85.76 | 1.2 | 1 |
          | testuser2 | testclass2 | passed | 76.89 | 2.4 | 1 |
        And  the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh1b | dhexport_version1elis | period | 5m |
        Then a "local_datahub_schedule" record with '{"plugin":"dhexport_version1elis"}' "should" exist
        And I wait "0" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "export_version1elis_scheduled_" log file should contain "Export file .* successfully created"
        And the Datahub "version1elis" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Status,Grade,Letter |
          | Student,Test,testuser,testuser,testcourse1,.*,.*,COMPLETED,85.76000,B |
          | Student,Test,testuser2,testuser2,testcourse2,.*,.*,COMPLETED,76.89000,C |
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "30" seconds
        # Add new class completions
        And the following ELIS class enrolments exist:
          | user_idnumber | class_idnumber | completestatus | grade | credits | locked |
          | testuser | testclass3 | passed | 98.25 | 3.6 | 1 |
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "version1elis" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Status,Grade,Letter |
          | Student,Test,testuser,testuser,testcourse3,.*,.*,COMPLETED,98.25000,A |
        And the Datahub "version1elis" export file "should not" contain lines:
          | line |
          | Student,Test,testuser,testuser,testcourse1,.*,.*,COMPLETED,85.76000,B |
          | Student,Test,testuser2,testuser2,testcourse2,.*,.*,COMPLETED,76.89000,C |

    # T33.15.2 ~ 3c
    Scenario: version1elis advanced schedule non-incremenatal export succeeds.
        Given the following ELIS class enrolments exist:
          | user_idnumber | class_idnumber | completestatus | grade | credits | locked |
          | testuser | testclass1 | passed | 95.76 | 1.2 | 1 |
          | testuser2 | testclass2 | failed | 16.89 | 0 | 1 |
        And the following config values are set as admin:
          | nonincremental | 1 | dhexport_version1elis |
        And the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh2c | dhexport_version1elis | advanced | {"runs":3,"frequency":5,"units":"minute"} |
        Then a "local_datahub_schedule" record with '{"plugin":"dhexport_version1elis"}' "should" exist
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "export_version1elis_scheduled_" log file should contain "Export file .*csv successfully created"
        And the Datahub "version1elis" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Status,Grade,Letter |
          | Student,Test,testuser,testuser,testcourse1,.*,.*,95.76000,A |
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "version1elis" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Status,Grade,Letter |
          | Student,Test,testuser,testuser,testcourse1,.*,.*,COMPLETED,95.76000,A |

    # T33.15.2 ~ 
    Scenario: version1elis advanced calendar schedule export succeeds.
        Given the following ELIS class enrolments exist:
          | user_idnumber | class_idnumber | completestatus | grade | credits | locked |
          | testuser | testclass1 | failed | 45.76 | 0.5 | 1 |
          | testuser2 | testclass2 | passed | 56.89 | 2.4 | 1 |
        And the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh3b | dhexport_version1elis | advanced | {"startdate":"-3 days +5 minutes","recurrence":"calendar",enddate:"+2 days","weekdays":"1,2,3,4,5,6,7","months":"this"} |
        Then a "local_datahub_schedule" record with '{"plugin":"dhexport_version1elis"}' "should" exist
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "export_version1elis_scheduled_" log file should contain "Export file .* successfully created"
        And the Datahub "version1elis" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Status,Grade,Letter |
          | Student,Test,testuser2,testuser2,testcourse2,.*,.*,COMPLETED,56.89000,F |

