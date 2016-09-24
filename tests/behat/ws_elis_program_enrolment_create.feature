@local @local_datahub

Feature: Web service requests can be made to create a program enrolment.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist
          | username | idnumber |
          | testreco19 | testreco19 |
        And the following ELIS programs exist
          | name | idnumber | reqcredits |
          | testProgramName | PRG-1 | 32.14 |


    # T33.26.7 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_create" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.7 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_create" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.7 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_create" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.7 #4
    Scenario: Missing user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_create" method with body:
         """
         {"data":{"program_idnumber":"PRG-1","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_program_enrolment_create_fail_invalid_user","message":"No unique user identified by {empty} was found."}
         """

    # T33.26.7 #5
    Scenario: Missing program field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_create" method with body:
         """
         {"data":{"user_idnumber":"testreco19","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: program_idnumber"}
         """

    # T33.26.7 #6
    Scenario: Invalid user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_create" method with body:
         """
         {"data":{"program_idnumber":"PRG-1","user_idnumber":"bogususerid","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_program_enrolment_create_fail_invalid_user","message":"No unique user identified by idnumber: 'bogususerid' was found."}
         """

    # T33.26.7 #7
    Scenario: Invalid program field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_create" method with body:
         """
         {"data":{"program_idnumber":"bogusProgram","user_idnumber":"testreco19","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_program_enrolment_create_fail_invalid_program","message":"Program identified by program_idnumber 'bogusProgram' is not a valid program."}
         """

    # T33.26.7 #8
    Scenario: Successfully create program enrolment.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_create" method with body:
         """
         {"data":{"program_idnumber":"PRG-1","user_idnumber":"testreco19","credits":1.1,"locked":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"program_enrolment_created","message":"User successfully enrolled into Program","record":{"credits":1.1,"locked":true}}
         """

