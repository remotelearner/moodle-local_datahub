@local @local_datahub @javascript @dhimport_version1elis
Feature: Import a version1elis file.

    Background:
        Given I log in as "admin"


    # T37.2 #1, #2, #3
    Scenario: version1elis create/update/delete user imports succeeds.
        Given I make a Datahub "version1elis" manual "user" import with file "user_create_t37_2.csv"
        Then I should see "All lines from import file user_create_t37_2.csv were successfully processed. (1 of 1)"
        Then the Datahub "import_version1elis_manual_user_" log file should contain '\[user_create_t37_2.csv line 2\] User with username "testusername", email "test@user.com", idnumber "testidnumber" successfully created.'
        Then a "local_elisprogram_usr" record with '{"idnumber":"testidnumber","username":"testusername","firstname":"testfirstname","lastname":"testlastname","country":"CA"}' "should" exist
        Then a "user" record with '{"idnumber":"testidnumber","username":"testusername","firstname":"testfirstname","lastname":"testlastname","country":"CA"}' "should" exist

        # T37.2 #2
        Given I make a Datahub "version1elis" manual "user" import with file "user_update_t37_2.csv"
        Then I should see "All lines from import file user_update_t37_2.csv were successfully processed. (1 of 1)"
        Then the Datahub "import_version1elis_manual_user_" log file should contain '\[user_update_t37_2.csv line 2\] User with username "testusername", email "test@user.com", idnumber "testidnumber" successfully updated.'
        Then a "local_elisprogram_usr" record with '{"idnumber":"testidnumber","username":"testusername","firstname":"testfirstnamechanged","lastname":"testlastnamechanged","country":"US"}' "should" exist

        # T37.2 #3
        Given I make a Datahub "version1elis" manual "user" import with file "user_delete_t37_2.csv"
        Then I should see "All lines from import file user_delete_t37_2.csv were successfully processed. (1 of 1)"
        Then the Datahub "import_version1elis_manual_user_" log file should contain '\[user_delete_t37_2.csv line 2\] User with username "testusername", email "test@user.com", idnumber "testidnumber" successfully deleted.'
        Then a "local_elisprogram_usr" record with '{"idnumber":"testidnumber","username":"testusername"}' "should not" exist
        Then a "user" record with '{"idnumber":"testidnumber","username":"testusername"}' "should not" exist

    # T37.3 #1, #2, #3
    Scenario: version1elis create/update/delete course imports succeeds.
        Given I make a Datahub "version1elis" manual "course" import with file "course_create_t37_3.csv"
        Then I should see "All lines from import file course_create_t37_3.csv were successfully processed. (1 of 1)"
        Then the Datahub "import_version1elis_manual_course_" log file should contain '\[course_create_t37_3.csv line 2\] Course description with idnumber "testcourseid" successfully created.'
        Then a "local_elisprogram_crs" record with '{"idnumber":"testcourseid","name":"testcourse"}' "should" exist

        # T37.3 #2
        Given I make a Datahub "version1elis" manual "course" import with file "course_update_t37_3.csv"
        Then I should see "All lines from import file course_update_t37_3.csv were successfully processed. (1 of 1)"
        Then the Datahub "import_version1elis_manual_course_" log file should contain '\[course_update_t37_3.csv line 2\] Course description with idnumber "testcourseid" successfully updated.'
        Then a "local_elisprogram_crs" record with '{"idnumber":"testcourseid","name":"testcourseupdated"}' "should" exist

        # T37.3 #3
        Given I make a Datahub "version1elis" manual "course" import with file "course_delete_t37_3.csv"
        Then I should see "All lines from import file course_delete_t37_3.csv were successfully processed. (1 of 1)"
        Then the Datahub "import_version1elis_manual_course_" log file should contain '\[course_delete_t37_3.csv line 2\] Course description with idnumber "testcourseid" successfully deleted.'
        Then a "local_elisprogram_crs" record with '{"idnumber":"testcourseid"}' "should not" exist

