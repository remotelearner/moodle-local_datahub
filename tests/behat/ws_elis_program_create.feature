@local @local_datahub
Feature: Web service requests can be made to create a program.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |

    #T33.26.22 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_create" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.22 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_create" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.22 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_create" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.22 #4
    Scenario: Missing name field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_create" method with body:
         """
         {"data":{"idnumber":"testProgramIdnumber"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: name"}
         """

    # T33.26.22 #5
    Scenario: Missing idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_create" method with body:
         """
         {"data":{"name":"testProgram"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"}
         """

    # T33.26.22 #6
    Scenario: Successfully create program.
       Given I make a datahub webservice request to the "local_datahub_elis_program_create" method with body:
         """
         {"data":{"name":"testProgram","idnumber":"testProgramIdnumber","description":"test program description","reqcredits":4.5,"timetocomplete":"6m","frequency":"1y", "priority":10}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"program_created","message":"Program created successfully","record":{"idnumber":"testProgramIdnumber","name":"testProgram","description":"test program description","reqcredits":4.5,"timetocomplete":"6m","frequency":"1y","priority":10}}
         """

    # T33.26.22 #7
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | program | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_program_create" method with body:
        """
        {"data":{"name":"testProgram2","idnumber":"testProgramIdnumber2","description":"test program2 description","reqcredits":6.5,"timetocomplete":"6m","frequency":"1y","priority":10,"field_custom1":"Option E"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"program_created","message":"Program created with custom field errors - see logs for details.","record":{"idnumber":"testProgramIdnumber2","name":"testProgram2","description":"test program2 description","reqcredits":6.5,"timetocomplete":"6m","frequency":"1y","priority":10,"field_custom1":"Option 4"}}
        """

    # T33.26.22 #7.1
    Scenario: Create with valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | program | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_program_create" method with body:
        """
        {"data":{"name":"testProgram3","idnumber":"testProgramIdnumber3","description":"test program3 description","reqcredits":8.5,"timetocomplete":"6m","frequency":"1y","priority":10,"field_custom1":"Option 1,Option 3"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"program_created","message":"Program created successfully","record":{"idnumber":"testProgramIdnumber3","name":"testProgram3","description":"test program3 description","reqcredits":8.5,"timetocomplete":"6m","frequency":"1y","priority":10,"field_custom1":"Option 1,Option 3"}}
        """

