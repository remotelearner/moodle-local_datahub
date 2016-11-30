@local @local_datahub @dh_ws
Feature: Web service requests can be made to delete an ELIS Class Instance.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS courses exist:
          | name | idnumber | credits | completion_grade |
          | Test Course A | T332621CRSa | 1.74 | 58 |
        And the following ELIS classes exist:
          | idnumber | course_idnumber |
          | T332621CLSa | T332621CRSa |


    # T33.26.21 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_delete" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.21 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_delete" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.21 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_delete" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.21 #4
    Scenario: Missing idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_delete" method with body:
         | body |
         | {"data":{"startdate":"Jan/01/2013"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"} |

    # T33.26.21 #5
    Scenario: Empty idnumber returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_delete" method with body:
         | body |
         | {"data":{"idnumber":""}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_class_delete_fail_invalid_idnumber","message":"Class idnumber: '' is not a valid class."} |

    # T33.26.21 #6
    Scenario: Invalid idnumber returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_delete" method with body:
         | body |
         | {"data":{"idnumber":"T332621CLSb"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_class_delete_fail_invalid_idnumber","message":"Class idnumber: 'T332621CLSb' is not a valid class."} |

    # T33.26.21 #7
    Scenario: Successfully delete ELIS Class.
       Given I make a datahub webservice request to the "local_datahub_elis_class_delete" method with body:
         | body |
         | {"data":{"idnumber":"T332621CLSa"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"class_deleted","message":"Class deleted successfully"} |

