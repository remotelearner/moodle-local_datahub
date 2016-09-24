@local @local_datahub

Feature: Web service requests can be made to create an ELIS Class Instance.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following "courses" exist:
          | fullname | shortname | format | enablecompletion |
          | Test MoodleCourse A | T332619MCa | topics | 1 |
        And the following ELIS programs exist
          | name | idnumber | reqcredits |
          | PROGRAM-A | T332619PGMa | 12.34 |
        And the following ELIS tracks exist
          | idnumber | name | program_idnumber |
          | T332619TRKa | Test Track A | T332619PGMa |
        And the following ELIS courses exist
          | name | idnumber | credits | completion_grade |
          | Test Course A | T332619CRSa | 1.34 | 55 |
        And the following ELIS classes exist
          | idnumber | course_idnumber |
          | T332619CLSa | T332619CRSa |


    # T33.26.19 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.19 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.19 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"}
         """

    # T33.26.19 #4
    Scenario: Missing fields returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{"startdate":"Jan/01/2013"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"}
         """

    # T33.26.19 #5
    Scenario: Missing idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{"startdate":"Jan/01/2013","assignment":"T332619CRSa"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"}
         """

    # T33.26.19 #6
    Scenario: Missing assignment returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{"startdate":"Jan/01/2013","idnumber":"T332619CLSb"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: assignment"}
         """

    # T33.26.19 #7
    Scenario: Duplicate idnumber returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{"startdate":"Jan/01/2013","idnumber":"T332619CLSa","assignment":"T332619CRSa"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"moodle_exception","errorcode":"ws_class_create_fail_duplicateidnumber","message":"Could not create class - duplicate idnumber received."}
         """

    # T33.26.19 #8
    Scenario: Invalid assignment returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{"startdate":"Jan/01/2013","idnumber":"T332619CLSb","assignment":"T332619CRSb"}}
         """
       Then I should receive from the datahub web service:
         """
         {"exception":"moodle_exception","errorcode":"ws_class_create_fail_invalidcourseassignment","message":"Could not create class - invalid course idnumber received for parameter \"assignment\""}
         """

    # T33.26.19 #9
    Scenario: Successfully create ELIS Class.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{"idnumber":"T332619CLSb","assignment":"T332619CRSa"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"class_created","message":"Class created successfully","record":{"idnumber":"T332619CLSb","startdate":0,"enddate":0,"duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"environmentid":0,"enrol_from_waitlist":false}}
         """

    # T33.26.19 #10
    Scenario: Assignment to Track.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{"startdate":"Jan/01/2013","enddate":"Feb/01/2013","idnumber":"T332619CLSc","assignment":"T332619CRSa","track":"T332619TRKa"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"class_created","message":"Class created successfully","record":{"idnumber":"T332619CLSc","duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"environmentid":0,"enrol_from_waitlist":false}}
         """

    # T33.26.19 #11
    Scenario: Assignment to Moodle Course.
       Given I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
         """
         {"data":{"startdate":"Jan/01/2013","enddate":"Feb/01/2013","idnumber":"T332619CLSd","assignment":"T332619CRSa","link":"T332619MCa"}}
         """
       Then I should receive from the datahub web service:
         """
         {"messagecode":"class_created","message":"Class created successfully","record":{"idnumber":"T332619CLSd","duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"environmentid":0,"enrol_from_waitlist":false}}
         """

    # T33.26.19 #12
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | class | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
        """
        {"data":{"startdate":"Jan/01/2013","enddate":"Feb/01/2013","idnumber":"T332619CLSe","assignment":"T332619CRSa","field_custom1":"Option E"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"class_created","message":"Class created with custom field errors - see logs for details.","record":{"idnumber":"T332619CLSe","duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"environmentid":0,"enrol_from_waitlist":false,"field_custom1":"Option 4"}}
        """

    # T33.26.19 #12.1
    Scenario: Create with valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | class | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_class_create" method with body:
        """
        {"data":{"startdate":"Jan/01/2013","enddate":"Feb/01/2013","idnumber":"T332619CLSdd","assignment":"T332619CRSa","field_custom1":"Option 1,Option 3"}}
        """
        Then I should receive from the datahub web service:
        """
        {"messagecode":"class_created","message":"Class created successfully","record":{"idnumber":"T332619CLSdd","duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"environmentid":0,"enrol_from_waitlist":false,"field_custom1":"Option 1,Option 3"}}
        """

