@local @local_datahub

Feature: Web service requests can be made to create an ELIS Class enrolment.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist
          | username | idnumber |
          | testreco23 | testreco23 |
        And the following ELIS courses exist
          | name | idnumber | credits | completion_grade |
          | Test Course | CRS-1 | 2.65 | 58 |
        And the following ELIS classes exist
          | idnumber | course_idnumber |
          | CLASS-1 | CRS-1 |


    # T33.26.11 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_create" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.11 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_create" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.11 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_create" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.11 #4
    Scenario: Missing user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_create" method with body:
         """
         {"data":{"class_idnumber":"CLASS-1","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_class_enrolment_create_fail_invalid_user","message":"No unique user identified by {empty} was found."}
         """

    # T33.26.11 #5
    Scenario: Missing class returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_create" method with body:
         """
         {"data":{"user_idnumber":"testreco23","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: class_idnumber"}
         """

    # T33.26.11 #6
    Scenario: Invalid user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_create" method with body:
         """
         {"data":{"class_idnumber":"CLASS-1","user_idnumber":"bogususerid","credits":1.1,"locked":1}}	
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_class_enrolment_create_fail_invalid_user","message":"No unique user identified by idnumber: 'bogususerid' was found."}
         """

    # T33.26.11 #7
    Scenario: Invalid class returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_create" method with body:
         """
         {"data":{"class_idnumber":"bogusClass","user_idnumber":"testreco23","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_class_enrolment_create_fail_invalid_class","message":"Class identified by class_idnumber 'bogusClass' is not a valid class."}
         """

    # T33.26.11 #8
    Scenario: Successfully create class enrolment.
       Given I make a datahub webservice request to the "local_datahub_elis_class_enrolment_create" method with body:
         """
         {"data":{"class_idnumber":"CLASS-1","user_idnumber":"testreco23","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"class_enrolment_created","message":"User successfully enrolled into Class","record":{"completetime":0,"endtime":0,"completestatusid":0,"grade":0,"credits":1.1,"locked":true}}
         """

