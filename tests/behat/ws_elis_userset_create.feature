@local @local_datahub
Feature: Web service requests can be made to create a userset.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |

    #T33.26.28 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_create" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.28 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_create" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.28 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_create" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.28 #4
    Scenario: Invalid parent returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_create" method with body:
         | body |
         | {"data":{"name":"TestUserset","display":"test userset description","parent":"BogusUserset"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_userset_create_fail_invalid_parent","message":"Userset parent: 'BogusUserset' is not a valid userset."} |

    # T33.26.28 #8
    Scenario: Successfully create userset.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_create" method with body:
         | body |
         | {"data":{"name":"TestUserset","display":"test userset description","parent":"top"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"userset_created","message":"Userset created successfully","record":{"name":"TestUserset","display":"test userset description","parent":0}} |

    # T33.26.28 #9
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | userset | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_userset_create" method with body:
         | body |
         | {"data":{"name":"TestUserset2","display":"test userset 2 description","parent":"top","field_custom1":"Option E"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"userset_created","message":"Userset created with custom field errors - see logs for details.","record":{"name":"TestUserset2","display":"test userset 2 description","parent":0,"field_custom1":"Option 4"}} |

    # T33.26.28 #9.1
    Scenario: Create with valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | userset | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_userset_create" method with body:
         | body |
         | {"data":{"name":"TestUserset3","display":"test userset 3 description","parent":"top","field_custom1":"Option 1,Option 3"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"userset_created","message":"Userset created successfully","record":{"name":"TestUserset3","display":"test userset 3 description","parent":0,"field_custom1":"Option 1,Option 3"}} |

