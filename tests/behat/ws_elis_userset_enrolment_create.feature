@local @local_datahub

Feature: Web service requests can be made to create a userset enrolment.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist
          | username | idnumber |
          | testreco26 | testreco26 |
        And the following ELIS usersets exist
          | name | parent_name |
          | US-1 | top |


    # T33.26.14 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_create" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.14 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_create" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.14 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_create" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.14 #4
    Scenario: Missing user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_create" method with body:
         """
         {"data":{"userset_name":"US-1","leader":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_userset_enrolment_create_fail_invalid_user","message":"No unique user identified by {empty} was found."}
         """

    # T33.26.14 #5
    Scenario: Missing userset field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_create" method with body:
         """
         {"data":{"user_idnumber":"testreco26","leader":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: userset_name"}
         """

    # T33.26.14 #6
    Scenario: Invalid user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_create" method with body:
         """
         {"data":{"userset_name":"US-1","user_idnumber":"bogususerid","leader":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_userset_enrolment_create_fail_invalid_user","message":"No unique user identified by idnumber: 'bogususerid' was found."}
         """

    # T33.26.14 #7
    Scenario: Invalid userset field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_create" method with body:
         """
         {"data":{"userset_name":"bogusUserset","user_idnumber":"testreco26","leader":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_userset_enrolment_create_fail_invalid_userset","message":"Userset identified by userset_name 'bogusUserset' is not a valid userset."}
         """

    # T33.26.14 #8
    Scenario: Successfully create userset enrolment.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_create" method with body:
         """
         {"data":{"userset_name":"US-1","user_idnumber":"testreco26","leader":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"userset_enrolment_created","message":"User successfully enrolled into Userset","record":{"plugin":"manual","leader":true}}
         """

