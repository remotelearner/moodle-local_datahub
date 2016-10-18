@local @local_datahub
Feature: Web service requests can be made to update an ELIS Class enrolment.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist:
          | username | idnumber |
          | testreco24 | testreco24 |
        And the following ELIS courses exist:
          | name | idnumber | credits | completion_grade |
          | Test Course | CRS-1 | 2.65 | 58 |
        And the following ELIS classes exist:
          | idnumber | course_idnumber |
          | CLASS-1 | CRS-1 |
        And the following ELIS class enrolments exist:
          | user_idnumber | class_idnumber | completestatus | grade | credits | locked |
          | testreco24 | CLASS-1 | notcompleted | 0 | 0 | 0 |


    # T33.26.12 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.12 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.12 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.12 #4
    Scenario: Missing user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {"data":{"class_idnumber":"CLASS-1","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_class_enrolment_update_fail_invalid_user","message":"No unique user identified by {empty} was found."}
         """

    # T33.26.12 #5
    Scenario: Missing class returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {"data":{"user_idnumber":"testreco24","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: class_idnumber"}
         """

    # T33.26.12 #6
    Scenario: Invalid user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {"data":{"class_idnumber":"CLASS-1","user_idnumber":"bogususerid","credits":1.1,"locked":1}}	
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_class_enrolment_update_fail_invalid_user","message":"No unique user identified by idnumber: 'bogususerid' was found."}
         """

    # T33.26.12 #7
    Scenario: Invalid class returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {"data":{"class_idnumber":"bogusClass","user_idnumber":"testreco24","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_class_enrolment_update_fail_invalid_class","message":"Class identified by class_idnumber 'bogusClass' is not a valid class."}
         """

    # T33.26.12 #8
    Scenario: Invalid enrolment time returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {"data":{"class_idnumber":"CLASS-1","user_idnumber":"testreco24","credits":1.1,"locked":1,"enrolmenttime":"bogusTime"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_class_enrolment_update_fail_invalid_enrolmenttime","message":"Class enrolment time: 'bogusTime' is not a valid date - must be in format MMM\/DD\/YYYY"}
         """

    # T33.26.12 #9
    Scenario: Invalid complete time returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {"data":{"class_idnumber":"CLASS-1","user_idnumber":"testreco24","credits":1.1,"locked":1,"completetime":"bogusTime"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_class_enrolment_update_fail_invalid_completetime","message":"Class completion time: 'bogusTime' is not a valid date - must be in format MMM\/DD\/YYYY"}
         """

    # T33.26.12 #10
    Scenario: Successfully update class enrolment.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_update" method with body:
         """
         {"data":{"class_idnumber":"CLASS-1","user_idnumber":"testreco24","grade":51,"credits":1.1,"locked":1,"enrolmenttime":"May/10/2013"}}	
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"class_enrolment_updated","message":"User class enrolment successfully updated","record":{"completetime":0,"endtime":0,"completestatusid":0,"grade":51,"credits":1.1,"locked":true}}
         """

