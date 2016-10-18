@local @local_datahub
Feature: Web service requests can be made to delete a track.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS programs exist:
          | name | idnumber | reqcredits |
          | TestProgram | TestProgramIdnumber | 12.34 |
        And the following ELIS tracks exist:
          | program_idnumber | name | idnumber |
          | TestProgramIdnumber | TestTrack | TestTrackIdnumber | 

    #T33.26.27 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_delete" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.27 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_delete" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.27 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_delete" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.27 #4
    Scenario: Invalid idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_delete" method with body:
         """
         {"data":{"idnumber":"BogusTrackIdnumber"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_track_delete_fail_invalid_idnumber","message":"Track idnumber: 'BogusTrackIdnumber' is not a valid track."}
         """

    # T33.26.27 #5
    Scenario: Successfully delete track.
       Given I make a datahub webservice request to the "local_datahub_elis_track_delete" method with body:
         """
         {"data":{"idnumber":"TestTrackIdnumber"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"track_deleted","message":"Track deleted successfully"}
         """

