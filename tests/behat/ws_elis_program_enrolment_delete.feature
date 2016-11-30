@local @local_datahub @dh_ws
Feature: Web service requests can be made to delete a program enrolment.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist:
          | username | idnumber |
          | testreco19 | testreco19 |
        And the following ELIS programs exist:
          | name | idnumber | reqcredits |
          | testProgramName | PRG-1 | 32.14 |
        And the following ELIS program enrolments exist:
          | user_idnumber | program_idnumber |
          | testreco19 | PRG-1 |


    # T33.26.8 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_delete" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.8 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_delete" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.8 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_delete" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.8 #4
    Scenario: Missing user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_delete" method with body:
         | body |
         | {"data":{"program_idnumber":"PRG-1"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_program_enrolment_delete_fail_invalid_user","message":"No unique user identified by {empty} was found."} |

    # T33.26.8 #5
    Scenario: Missing program field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_delete" method with body:
         | body |
         | {"data":{"user_idnumber":"testreco19"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: program_idnumber"} |

    # T33.26.8 #6
    Scenario: Invalid user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_delete" method with body:
         | body |
         | {"data":{"program_idnumber":"PRG-1","user_idnumber":"bogususerid"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_program_enrolment_delete_fail_invalid_user","message":"No unique user identified by idnumber: 'bogususerid' was found."} |

    # T33.26.8 #7
    Scenario: Invalid program field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_delete" method with body:
         | body |
         | {"data":{"program_idnumber":"bogusProgram","user_idnumber":"testreco19"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_program_enrolment_delete_fail_invalid_program","message":"Program identified by program_idnumber 'bogusProgram' is not a valid program."} |

    # T33.26.8 #8
    Scenario: Successfully delete program enrolment.
       Given I make a datahub webservice request to the "local_datahub_elis_program_enrolment_delete" method with body:
         | body |
         | {"data":{"program_idnumber":"PRG-1","user_idnumber":"testreco19"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"program_enrolment_deleted","message":"User successfully unenrolled from Program"} |

