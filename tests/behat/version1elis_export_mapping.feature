@local @local_datahub @javascript @dhexport_version1elis @dh_nophantom
Feature: version1elis export mapping.

    Background:
        Given I log in as "admin"
        And the following ELIS custom fields exist:
          | category | name | contextlevel | datatype | control | multi | options | default |
          | custom1 | class1 | class | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
          | custom1 | course1 | course | text | text | 0 | | Default course text |
          | custom1 | user1 | user | text | text | 0 | | Default user text |
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


    # T37.37 ?
    Scenario: version1elis basic/period schedule export field mappings.
        Given I add the following fields for version1elis export:
          | contextlevel | field |
          | user | email |
          | user | user1 |
          | course | course1 |
          | class | class1 |
          | student | credits |
        And  the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh1b | dhexport_version1elis | period | 5m |
        And the following ELIS class enrolments exist:
          | user_idnumber | class_idnumber | completestatus | grade | credits | locked |
          | testuser | testclass1 | passed | 85.76 | 1.2 | 1 |
          | testuser2 | testclass2 | passed | 76.89 | 2.4 | 1 |
        Then a "local_datahub_schedule" record with '{"plugin":"dhexport_version1elis"}' "should" exist
        And I wait "0" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the Datahub "export_version1elis_scheduled_" log file should contain "Export file .* successfully created"
        And the Datahub "version1elis" export file "should" contain lines:
          | line |
          | "First Name","Last Name",Username,"User Idnumber","Course Idnumber","Start Date","End Date",Status,Grade,Letter,email,user1,course1,class1,credits |
          | Student,Test,testuser,testuser,testcourse1,.*,.*,COMPLETED,85.76000,B,testuser@example.com,"Default user text","Default course text","Option 4",1.20 |
          | Student,Test,testuser2,testuser2,testcourse2,.*,.*,COMPLETED,76.89000,C,testuser2@example.com,"Default user text","Default course text","Option 4",2.40 |

