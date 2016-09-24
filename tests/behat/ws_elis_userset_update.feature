@local @local_datahub

Feature: Web service requests can be made to update a userset.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
         And the following ELIS usersets exist
          | name | parent_name |
          | TestUserset | top |

    # T33.26.29 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_update" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.29 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_update" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.29 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_update" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.29 #4
    Scenario: Invalid name returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_update" method with body:
         """
         {"data":{"name":"BogusUserset"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_userset_update_fail_invalid_name","message":"Userset name: 'BogusUserset' is not a valid userset."}
         """

    # T33.26.29 #5
    Scenario: Invalid parent returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_update" method with body:
         """
         {"data":{"name":"TestUserset","display":"test userset description","parent":"BogusUserset"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_userset_update_fail_invalid_parent","message":"Userset parent: 'BogusUserset' is not a valid userset."}
         """

    # T33.26.29 #6
    Scenario: Successfully update userset.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_update" method with body:
         """
         {"data":{"name":"TestUserset","display":"test userset description","parent":"top"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"userset_updated","message":"Userset updated successfully","record":{"name":"TestUserset","display":"test userset description","parent":0}}
         """

    # T33.26.29 #7
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | userset | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_userset_update" method with body:
        """
        {"data":{"name":"TestUserset","field_custom1":"Option E"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"userset_updated","message":"Userset updated with custom field errors - see logs for details.","record":{"name":"TestUserset","display":"TestUserset","parent":0,"field_custom1":"Option 4"}}
        """

    # T33.26.29 #7.1
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | userset | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_userset_update" method with body:
        """
        {"data":{"name":"TestUserset","field_custom1":"Option 1,Option 3"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"userset_updated","message":"Userset updated successfully","record":{"name":"TestUserset","display":"TestUserset","parent":0,"field_custom1":"Option 1,Option 3"}}
        """

