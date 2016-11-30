@local @local_datahub @dh_ws
Feature: Web service requests can be made to create a track enrolment.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist:
          | username | idnumber |
          | testreco21 | testreco21 |
        And the following ELIS programs exist:
          | name | idnumber | reqcredits |
          | testProgramName | PRG-1 | 32.14 |
        And the following ELIS tracks exist:
          | name | idnumber | program_idnumber |
          | testTrackName | TRK-1 | PRG-1 |


    # T33.26.9 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_enrolment_create" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.9 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_enrolment_create" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.9 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_enrolment_create" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.9 #4
    Scenario: Missing user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_enrolment_create" method with body:
         | body |
         | {"data":{"track_idnumber":"TRK-1"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_track_enrolment_create_fail_invalid_user","message":"User identified by {empty} was not found."} |

    # T33.26.9 #5
    Scenario: Missing track field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_enrolment_create" method with body:
         | body |
         | {"data":{"user_idnumber":"testreco21"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: track_idnumber"} |

    # T33.26.9 #6
    Scenario: Invalid user fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_enrolment_create" method with body:
         | body |
         | {"data":{"track_idnumber":"TRK-1","user_idnumber":"bogususerid"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_track_enrolment_create_fail_invalid_user","message":"User identified by idnumber: 'bogususerid' was not found."} |

    # T33.26.9 #7
    Scenario: Invalid track field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_enrolment_create" method with body:
         | body |
         | {"data":{"track_idnumber":"bogustrack","user_idnumber":"testreco21"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_track_enrolment_create_fail_invalid_track","message":"Track identified by track_idnumber 'bogustrack' is not a valid track."} |

    # T33.26.9 #8
    Scenario: Successfully create track enrolment.
       Given I make a datahub webservice request to the "local_datahub_elis_track_enrolment_create" method with body:
         | body |
         | {"data":{"track_idnumber":"TRK-1","user_idnumber":"testreco21"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"track_enrolment_created","message":"User successfully enrolled into track","record":{}} |

