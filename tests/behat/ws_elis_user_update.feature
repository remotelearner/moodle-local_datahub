@local @local_datahub

Feature: Web service requests can be made to update a user.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS users exist
          | username | idnumber |
          | T33262a | T33262a |
          | T33262b | T33262b |

    #T33.26.2 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.2 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.2 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.2 #4
    Scenario: Sending no identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         {"data":{"firstname":"NewFirstName"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"moodle_exception","errorcode":"ws_user_update_fail_noidfields","message":"No valid identifying fields received"}
         """

    # T33.26.2 #5
    Scenario: Sending invalid identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         {"data":{"username":"T33262c","firstname":"NewFirstFirst"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"moodle_exception","errorcode":"ws_user_update_fail_noidfields","message":"No valid identifying fields received"}
         """

    # T33.26.2 #6
    Scenario: Trying to update identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         {"data":{"username":"T33262a","idnumber":"T33262c"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"moodle_exception","errorcode":"ws_user_update_fail_idfieldsnotallowed","message":"Identifying fields cannot be updated using this method. Please use local_datahub_elis_user_update_identifiers() instead."}
         """

    # T33.26.2 #7
    Scenario: Sending conflicting identifying fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         {"data":{"username":"T33262b","idnumber":"T33262a","firstname":"NewFirstFirst"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"moodle_exception","errorcode":"ws_user_update_fail_conflictingidfields","message":"Conflicting identifying fields received: supplied idnumber, username do not refer to the same user."}
         """

    # T33.26.2 #8
    Scenario: Success with single identifying field.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         {"data":{"username":"T33262a","firstname":"NewFirstFirst"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"user_updated","message":"User updated successfully","record":{"username":"t33262a","password":"","idnumber":"T33262a","firstname":"NewFirstFirst","lastname":"Test","mi":null,"email":"T33262a@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false}}
         """

    # T33.26.2 #9
    Scenario: Success with 2 identifying fields.
       Given I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
         """
         {"data":{"username":"T33262b","idnumber":"T33262b","firstname":"NewFirstFirst"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"user_updated","message":"User updated successfully","record":{"username":"t33262b","password":"","idnumber":"T33262b","firstname":"NewFirstFirst","lastname":"Test","mi":null,"email":"T33262b@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false}}
         """

    # T33.26.2 #10
    Scenario: Update invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | user | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
        """
        {"data":{"username":"T33262a","idnumber":"T33262a","field_custom1":"Option E"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"user_updated","message":"User updated with custom field errors - see logs for details.","record":{"username":"t33262a","password":"","idnumber":"T33262a","firstname":"Student","lastname":"Test","mi":null,"email":"T33262a@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false,"field_custom1":"Option 4"}}
        """

    # T33.26.2 #10.1
    Scenario: Update valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | user | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_user_update" method with body:
        """
        {"data":{"username":"T33262b","idnumber":"T33262b","field_custom1":"Option 1,Option 3"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"user_updated","message":"User updated successfully","record":{"username":"t33262b","password":"","idnumber":"T33262b","firstname":"Student","lastname":"Test","mi":null,"email":"T33262b@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false,"field_custom1":"Option 1,Option 3"}}
        """

