@local @local_datahub

Feature: Web service requests can be made to delete an ELIS Course Description.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following "courses" exist:
          | fullname | shortname | format | enablecompletion |
          | MoodleCourse 1 |  MDLCRS-1 | topics | 1 |
        And the following ELIS programs exist
          | name | idnumber | reqcredits |
          | PROGRAM-1 | PRG-1 | 12.34 |
        And the following ELIS courses exist
          | name | idnumber | credits | completion_grade |
          | Test Course | CRS-1 | 2.34 | 53 |

    # T33.26.18 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_delete" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.18 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_delete" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.18 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_delete" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.18 #4
    Scenario: Invalid idnumber returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_delete" method with body:
         """
         {"data":{"idnumber":"boguscourse"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_course_delete_fail_invalid_idnumber","message":"Course idnumber: 'boguscourse' is not a valid ELIS course."}
         """

    # T33.26.18 #5
    Scenario: Successfully delete ELIS Course Description.
       Given I make a datahub webservice request to the "local_datahub_elis_course_delete" method with body:
         """
         {"data":{"idnumber":"CRS-1"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"course_deleted","message":"ELIS course deleted successfully"}
         """

