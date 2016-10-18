@local @local_datahub
Feature: Web service requests can be made to create a user.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |

    #T33.26.1 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.1 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.1 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.1 #4
    Scenario: Sending no username returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {"data":{"idnumber":"test","email":"test@example.com","country":"CA","firstname":"First","lastname":"Last"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: username"}
         """

    # T33.26.1 #5
    Scenario: Sending no idnumber returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {"data":{"username":"test","email":"test@example.com","country":"CA","firstname":"First","lastname":"Last"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"}
         """

    # T33.26.1 #6
    Scenario: Sending no email returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {"data":{"username":"test", "idnumber":"test","country":"CA","firstname":"First","lastname":"Last"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: email"}
         """

    # T33.26.1 #7
    Scenario: Sending no country returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {"data":{"username":"test", "idnumber":"test", "email":"test@example.com", "firstname":"First","lastname":"Last"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: country"}
         """

    # T33.26.1 #8
    Scenario: Sending no first name returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {"data":{"username":"test", "idnumber":"test", "email":"test@example.com", "country":"CA","lastname":"Last"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: firstname"}
         """

    # T33.26.1 #9
    Scenario: Sending no last name returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {"data":{"username":"test", "idnumber":"test", "email":"test@example.com", "country":"CA","firstname":"First"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: lastname"}
         """

    # T33.26.1 #10
    Scenario: Sending all required fields successfully creates user.
       Given I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
         """
         {"data":{"username":"test", "idnumber":"test", "email":"test@example.com", "country":"CA","firstname":"First","lastname":"Last"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"user_created","message":"User created successfully","record":{"username":"test","password":"","idnumber":"test","firstname":"First","lastname":"Last","mi":null,"email":"test@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"CA","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false}}
         """

    # T33.26.1 #11
    Scenario: Creation validates illegal multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | user | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
        """
        {"data":{"username":"test2","idnumber":"test2","email":"test2@example.com","country":"CA","firstname":"First","lastname":"Last2","field_custom1":"Option E"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"user_created","message":"User created with custom field errors - see logs for details.","record":{"username":"test2","password":"","idnumber":"test2","firstname":"First","lastname":"Last2","mi":null,"email":"test2@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"CA","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false,"field_custom1":"Option 4"}}
        """

    # T33.26.1 #11.1
    Scenario: Creation validates legal multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | user | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_user_create" method with body:
        """
        {"data":{"username":"test3","idnumber":"test3","email":"test3@example.com","country":"CA","firstname":"First","lastname":"Last3","field_custom1":"Option 1,Option 3"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"user_created","message":"User created successfully","record":{"username":"test3","password":"","idnumber":"test3","firstname":"First","lastname":"Last3","mi":null,"email":"test3@example.com","email2":null,"address":"","address2":null,"city":"","state":null,"postalcode":null,"country":"CA","phone":null,"phone2":null,"fax":null,"birthdate":null,"gender":null,"language":"en","transfercredits":0,"comments":null,"notes":null,"inactive":false,"field_custom1":"Option 1,Option 3"}}
        """

