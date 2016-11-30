@local @local_datahub @dh_ws
Feature: Web service requests can be made to update an ELIS Class Instance.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following "courses" exist:
          | fullname | shortname | format | enablecompletion |
          | Test MoodleCourse A | T332620MCa | topics | 1 |
        And the following ELIS programs exist:
          | name | idnumber | reqcredits |
          | PROGRAM-A | T332620PGMa | 12.34 |
        And the following ELIS tracks exist:
          | idnumber | name | program_idnumber |
          | T332620TRKa | Test Track A | T332620PGMa |
        And the following ELIS courses exist:
          | name | idnumber | credits | completion_grade |
          | Test Course A | T332620CRSa | 1.34 | 55 |
        And the following ELIS classes exist:
          | idnumber | course_idnumber |
          | T332620CLSa | T332620CRSa |


    # T33.26.20 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.20 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.20 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.20 #4
    Scenario: Missing idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{"startdate":"Jan/01/2013"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"} |

    # T33.26.20 #5
    Scenario: Invalid class returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{"startdate":"Jan/01/2013","idnumber":"T332620CLSb"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"moodle_exception","errorcode":"ws_class_update_fail_badidnumber","message":"Could not find class with that idnumber."} |

    # T33.26.20 #6
    Scenario: Attempt to re-assign returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{"idnumber":"T332620CLSa","assignment":"T332620CRSb"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"moodle_exception","errorcode":"ws_class_update_fail_cannotreassign","message":"Class instance was not re-assigned to course description because moving class instances between course descriptions is not supported."} |

    # T33.26.20 #7
    Scenario: Successfully update ELIS Class.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{"idnumber":"T332620CLSa","enrol_from_waitlist":true}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"class_updated","message":"Class updated successfully","record":{"idnumber":"T332620CLSa","startdate":0,"enddate":0,"duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"enrol_from_waitlist":true}} |

    # T33.26.20 #8
    Scenario: Successfully update ELIS Class track assignment.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{"idnumber":"T332620CLSa","track":"T332620TRKa"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"class_updated","message":"Class updated successfully","record":{"idnumber":"T332620CLSa","startdate":0,"enddate":0,"duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"enrol_from_waitlist":false}} |

    # T33.26.20 #9
    Scenario: Successfully update ELIS Class Moodle course assignment.
       Given I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{"idnumber":"T332620CLSa","link":"T332620MCa"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"class_updated","message":"Class updated successfully","record":{"idnumber":"T332620CLSa","startdate":0,"enddate":0,"duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"enrol_from_waitlist":false}} |

    # T33.26.20 #10
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | class | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{"idnumber":"T332620CLSa","field_custom1":"Option E"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"class_updated","message":"Class updated with custom field errors - see logs for details.","record":{"idnumber":"T332620CLSa","startdate":0,"enddate":0,"duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"enrol_from_waitlist":false,"field_custom1":"Option 4"}} |

    # T33.26.20 #10.1
    Scenario: Create with valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | class | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_class_update" method with body:
         | body |
         | {"data":{"idnumber":"T332620CLSa","field_custom1":"Option 1,Option 3"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"class_updated","message":"Class updated successfully","record":{"idnumber":"T332620CLSa","startdate":0,"enddate":0,"duration":0,"starttimehour":0,"starttimeminute":0,"endtimehour":0,"endtimeminute":0,"maxstudents":0,"enrol_from_waitlist":false,"field_custom1":"Option 1,Option 3"}} |

