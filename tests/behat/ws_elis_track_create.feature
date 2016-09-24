@local @local_datahub

Feature: Web service requests can be made to create a track.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following ELIS programs exist
          | name | idnumber | reqcredits |
          | testProgram | testProgramIdnumber | 12.34 |

    #T33.26.25 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.25 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    #T33.26.25 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.25 #4
    Scenario: Missing name field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
         """
         {"data":{"idnumber":"testTrackkIdnumber","assignment":"TestProgramIdnumber"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: name"}
         """

    # T33.26.25 #5
    Scenario: Missing idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
         """
         {"data":{"name":"testTrack","assignment":"TestProgramIdnumber"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"}
         """

    # T33.26.25 #6
    Scenario: Missing assignment field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
         """
         {"data":{"name":"testTrack","idnumber":"testTrackkIdnumber"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: assignment"}
         """

    # T33.26.25 #7
    Scenario: Invalid assignment field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
         """
         {"data":{"name":"testTrack","idnumber":"testTrackkIdnumber","assignment":"BogusProgram"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"data_object_exception","errorcode":"ws_track_create_fail_invalid_assignment","message":"Track assignment: 'BogusProgram' is not a valid program idnumber."}
         """

    # T33.26.25 #8
    Scenario: Successfully create track.
       Given I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
         """
         {"data":{"name":"testTrack", "idnumber":"testTrackIdnumber", "description":"test track description","assignment":"TestProgramIdnumber","autocreate":1}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"track_created","message":"Track created successfully","record":{"idnumber":"testTrackIdnumber","name":"testTrack","description":"test track description","startdate":0,"enddate":0}}
         """

    # T33.26.25 #9
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | track | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
        """
        {"data":{"name":"testTrack2","idnumber":"testTrackIdnumber2","description":"test track 2 description","assignment":"TestProgramIdnumber","startdate":"Jan/05/2013","enddate":"Jun/05/2013","autocreate":1,"field_custom1":"Option E"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"track_created","message":"Track created with custom field errors - see logs for details.","record":{"idnumber":"testTrackIdnumber2","name":"testTrack2","description":"test track 2 description","field_custom1":"Option 4"}}
        """

    # T33.26.25 #9.1
    Scenario: Create with valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | track | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_track_create" method with body:
        """
        {"data":{"name":"testTrack3","idnumber":"testTrackIdnumber3","description":"test track 3 description","assignment":"TestProgramIdnumber","startdate":"Jan/05/2013","enddate":"Jun/05/2013","autocreate":1,"field_custom1":"Option 1,Option 3"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"track_created","message":"Track created successfully","record":{"idnumber":"testTrackIdnumber3","name":"testTrack3","description":"test track 3 description","field_custom1":"Option 1,Option 3"}}
        """

