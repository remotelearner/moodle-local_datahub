@local @local_datahub
Feature: Web service requests can be made to update a program.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS programs exist:
          | name | idnumber | reqcredits |
          | testProgramName | testProgramIdnumber | 12.34 |
          | testProgramName2 | testProgramIdnumber2 | 9.87 |

    #T33.26.23 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_update" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.23 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_update" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.23 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_update" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.23 #4
    Scenario: Missing idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_update" method with body:
         | body |
         | {"data":{"name":"testProgramName"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"} |

    # T33.26.23 #5
    Scenario: Invalid program idnumber returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_update" method with body:
         | body |
         | {"data":{"idnumber":"bogusProgram"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_program_update_fail_invalid_idnumber","message":"Program idnumber: 'bogusProgram' is not a valid program."} |

    # T33.26.23 #6
    Scenario: Successfully update program.
       Given I make a datahub webservice request to the "local_datahub_elis_program_update" method with body:
         | body |
         | {"data":{"idnumber":"testProgramIdnumber","name":"NewProgramName","description":"test program description","reqcredits":4.5,"timetocomplete":"6m","frequency":"1y","priority":10}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"program_updated","message":"Program updated successfully","record":{"idnumber":"testProgramIdnumber","name":"NewProgramName","description":"test program description","reqcredits":4.5,"timetocomplete":"6m","frequency":"1y","priority":10}} |

    # T33.26.23 #7
    Scenario: Update with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | program | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_program_update" method with body:
         | body |
         | {"data":{"idnumber":"testProgramIdnumber","field_custom1":"Option E"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"program_updated","message":"Program updated with custom field errors - see logs for details.","record":{"idnumber":"testProgramIdnumber","name":"testProgramName","description":"Description of the Program","reqcredits":12.34,"timetocomplete":"","frequency":"","priority":0,"field_custom1":"Option 4"}} |

    # T33.26.23 #7.1
    Scenario: Update with valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | program | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_program_update" method with body:
         | body |
         | {"data":{"idnumber":"testProgramIdnumber","field_custom1":"Option 1,Option 3"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"program_updated","message":"Program updated successfully","record":{"idnumber":"testProgramIdnumber","name":"testProgramName","description":"Description of the Program","reqcredits":12.34,"timetocomplete":"","frequency":"","priority":0,"field_custom1":"Option 1,Option 3"}} |

