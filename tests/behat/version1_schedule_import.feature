@local @local_datahub @javascript @dhimport_version1
Feature: Import a version1 file.

    Background:
        Given I log in as "admin"


    # T33.15.1 ~ 2a
    Scenario: version1 basic/period schedule user import succeeds.
        Given the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh1 | dhimport_version1 | period | 5m |
        Then a "local_datahub_schedule" record with '{"plugin":"dhimport_version1"}' "should" exist
        And I wait "0" minutes and run cron
        And I upload file "create_user_t33_6.csv" for "version1" "user" import
        # We do multiple smaller waits instead of one longer wait to provide frequent feedback.
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And a "user" record with '{"idnumber":"testuser","username":"testuser","firstname":"Test","lastname":"User","city":"testcity","country":"CA"}' "should" exist
        And a "user" record with '{"username":"testuser2","firstname":"Test","lastname":"User2","city":"testcity","country":"CA"}' "should" exist

    # T33.15.2 ~ 3
    Scenario: version1 advanced schedule course import succeeds.
        Given the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh2a | dhimport_version1 | advanced | {"runs":3,"frequency":5,"units":"minute"} |
        Then a "local_datahub_schedule" record with '{"plugin":"dhimport_version1"}' "should" exist
        And I wait "0" minutes and run cron
        And I upload file "create_course_t33_6.csv" for "version1" "course" import
        # We do multiple smaller waits instead of one longer wait to provide frequent feedback.
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And a "course" record with '{"shortname":"testcourse2","fullname":"testcourse2"}' "should" exist

    # T33.15.2 ~ 2
    Scenario: version1 advanced schedule enrolment import succeeds.
        Given the following "users" exist:
          | username | firstname | lastname | email |
          | testuser | Test | User | testuser@email.com |
        And the following "courses" exist:
          | fullname | shortname | format |
          | Test Cousre 2 | testcourse2 | topics |
        And the following scheduled Datahub jobs exist:
          | label | plugin | type | params |
          | dh2b | dhimport_version1 | advanced | {"startdate":"+5 minutes","enddate":"+2 days"} |
        Then a "local_datahub_schedule" record with '{"plugin":"dhimport_version1"}' "should" exist
        And I wait "0" minutes and run cron
        And I upload file "version1_create_enrolment.csv" for "version1" "enrolment" import
        And I wait "5" minutes and run cron
        # We do multiple smaller waits instead of one longer wait to provide frequent feedback.
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "60" seconds
        And I wait "30" seconds
        And I wait "1" minutes and run cron
        Then I should see "Running s:9:\"run_ipjob\";(ipjob_"
        And the following enrolments should exist:
           | course | user |
           | testcourse2 | testuser |

