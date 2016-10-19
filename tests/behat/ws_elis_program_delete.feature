@local @local_datahub
Feature: Web service requests can be made to delete a program.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS programs exist:
          | name | idnumber | reqcredits |
          | testProgramName | testProgramIdnumber | 12.34 |

    #T33.26.24 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_delete" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.24 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_delete" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.24 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_program_delete" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.24 #4
    Scenario: Invalid Program.
       Given I make a datahub webservice request to the "local_datahub_elis_program_delete" method with body:
         | body |
         | {"data":{"idnumber":"bogusProgram"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_program_delete_fail_invalid_idnumber","message":"Program idnumber: 'bogusProgram' is not a valid program."} |

    # T33.26.24 #5
    Scenario: Successfully delete program.
       Given I make a datahub webservice request to the "local_datahub_elis_program_delete" method with body:
         | body |
         | {"data":{"idnumber":"testProgramIdnumber"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"program_deleted","message":"Program deleted successfully"} |

