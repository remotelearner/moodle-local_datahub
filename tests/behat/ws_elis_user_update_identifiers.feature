@local @local_datahub
Feature: Web service requests can be made to update a user identifiers.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist:
          | username | idnumber |
          | T33263a | T33263a |
          | T33263b | T33263b |

    #T33.26.3 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update_identifiers" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.3 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update_identifiers" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.3 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update_identifiers" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.3 #4
    Scenario: Sending no identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update_identifiers" method with body:
         """
         {"data":{"username":"T33263a"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_user_update_identifiers_fail_invalid_user","message":"No unique user identified by {empty} was found."}
         """

    # T33.26.3 #5
    Scenario: Sending invalid identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update_identifiers" method with body:
         """
         {"data":{"user_username":"T33263c","username":"T33263cNEW"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_user_update_identifiers_fail_invalid_user","message":"No unique user identified by username: 'T33263c' was found."}
         """

    # T33.26.3 #6
    Scenario: Sending conflicting identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update_identifiers" method with body:
         """
         {"data":{"user_username":"T33263a","user_idnumber":"T33263b","username":"T33263D"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_user_update_identifiers_fail_invalid_user","message":"No unique user identified by username: 'T33263a', idnumber: 'T33263b' was found."}
         """

    # T33.26.3 #7
    Scenario: Success with single identifying field.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update_identifiers" method with body:
         """
         {"data":{"user_username":"T33263a","username":"T33263aNEW"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"user_identfiers_updated","message":"User identifiers updated successfully","record":{"username":"T33263aNEW","password":"","idnumber":"T33263a","firstname":"Student","lastname":"Test","mi":null,"email":"T33263a@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false}}
         """

    # T33.26.3 #8
    Scenario: Success with 2 identifying fields.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update_identifiers" method with body:
         """
         {"data":{"user_username":"T33263b","user_idnumber":"T33263b","idnumber":"T33263bNEW"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"user_identfiers_updated","message":"User identifiers updated successfully","record":{"username":"T33263b","password":"","idnumber":"T33263bNEW","firstname":"Student","lastname":"Test","mi":null,"email":"T33263b@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false}}
         """

