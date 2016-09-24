@local @local_datahub

Feature: Web service requests can be made to delete a userset.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
         And the following ELIS usersets exist
          | name | parent_name |
          | TestUserset | top |

    # T33.26.30 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_delete" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.30 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_delete" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.30 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_delete" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.30 #4
    Scenario: Invalid name returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_delete" method with body:
         """
         {"data":{"name":"BogusUserset"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_userset_delete_fail_invalid_name","message":"Userset name: 'BogusUserset' is not a valid userset."}
         """

    # T33.26.28 #5
    Scenario: Successfully delete userset.
       Given I make a datahub webservice request to the "local_datahub_elis_userset_delete" method with body:
         """
         {"data":{"name":"TestUserset"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"userset_deleted","message":"Userset deleted successfully"}
         """

