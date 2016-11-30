@local @local_datahub @dh_ws
Feature: Web service requests can be made to delete a userset enrolment.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist:
          | username | idnumber |
          | testreco27 | testreco27 |
        And the following ELIS usersets exist:
          | name | parent_name |
          | US-1 | top |
        And the following ELIS userset enrolments exist:
          | userset_name | user_idnumber | plugin |
          | US-1 | testreco27 | manual |


    # T33.26.15 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_delete" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.15 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_delete" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.15 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_delete" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.15 #4
    Scenario: Missing user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_delete" method with body:
         | body |
         | {"data":{"userset_name":"US-1"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_userset_enrolment_delete_fail_invalid_user","message":"No unique user identified by {empty} was found."} |

    # T33.26.15 #5
    Scenario: Missing userset field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_delete" method with body:
         | body |
         | {"data":{"user_idnumber":"testreco27"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: userset_name"} |

    # T33.26.15 #6
    Scenario: Invalid user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_delete" method with body:
         | body |
         | {"data":{"userset_name":"US-1","user_idnumber":"bogususerid"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_userset_enrolment_delete_fail_invalid_user","message":"No unique user identified by idnumber: 'bogususerid' was found."} |

    # T33.26.15 #7
    Scenario: Invalid userset field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_delete" method with body:
         | body |
         | {"data":{"userset_name":"bogusUserset","user_idnumber":"testreco27"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_userset_enrolment_delete_fail_invalid_userset","message":"Userset identified by userset_name 'bogusUserset' is not a valid userset."} |

    # T33.26.15 #8
    Scenario: Successfully delete userset enrolment.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_enrolment_delete" method with body:
         | body |
         | {"data":{"userset_name":"US-1","user_idnumber":"testreco27"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"userset_enrolment_deleted","message":"User successfully unenrolled from Userset"} |

