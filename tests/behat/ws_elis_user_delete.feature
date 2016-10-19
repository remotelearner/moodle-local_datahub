@local @local_datahub
Feature: Web service requests can be made to delete a user.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist:
          | username | idnumber |
          | T33262a | T33262a |
          | T33262b | T33262b |

    #T33.26.4 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_delete" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.4 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_delete" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.4 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_delete" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.4 #4
    Scenario: Sending no identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_delete" method with body:
         | body |
         | {"data":{"firstname":"NewFirstName"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Unexpected keys (firstname) detected in parameter array."} |

    # T33.26.4 #5
    Scenario: Sending invalid identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_delete" method with body:
         | body |
         | {"data":{"username":"T33262c"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"moodle_exception","errorcode":"ws_user_delete_fail_noidfields","message":"No valid identifying fields received"} |

    # T33.26.4 #6
    Scenario: Sending conflicting identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_delete" method with body:
         | body |
         | {"data":{"username":"T33262b","idnumber":"T33262a"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"moodle_exception","errorcode":"ws_user_delete_fail_conflictingidfields","message":"Conflicting identifying fields received"} |

    # T33.26.4 #7
    Scenario: Success with single identifying field.
       Given I make a datahub webservice request to the "local_datahub_elis_user_delete" method with body:
         | body |
         | {"data":{"username":"T33262a"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"user_deleted","message":"User deleted successfully"} |

    # T33.26.4 #8
    Scenario: Success with 2 identifying fields.
       Given I make a datahub webservice request to the "local_datahub_elis_user_delete" method with body:
         | body |
         | {"data":{"username":"T33262b","idnumber":"T33262b"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"user_deleted","message":"User deleted successfully"} |

