@local @local_datahub @dh_ws
Feature: Web service requests can be made to create an ELIS Course Description.

    Background:
        Given the following config values are set as admin:
          | enablewebservices | 1 |
          | webserviceprotocols | rest |
        And the following "courses" exist:
          | fullname | shortname | format | enablecompletion |
          | MoodleCourse 1 |  MDLCRS-1 | topics | 1 |
        And the following ELIS programs exist:
          | name | idnumber | reqcredits |
          | PROGRAM-1 | PRG-1 | 12.34 |

    #T33.26.16 #1
    Scenario: Sending no data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.16 #2
    Scenario: Sending empty JSON data returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    #T33.26.16 #3
    Scenario: Sending empty data structure returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"Missing required key in single structure: data"} |

    # T33.26.16 #4
    Scenario: Missing idnumber field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"name":"Test Course"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: idnumber"} |

    # T33.26.16 #5
    Scenario: Missing name field returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"idnumber":"CRS-1"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"invalid_parameter_exception","errorcode":"invalidparameter","message":"Invalid parameter value detected","debuginfo":"data => Invalid parameter value detected: Missing required key in single structure: name"} |

    # T33.26.16 #6
    Scenario: Invalid credits returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"idnumber":"CRS-1","name":"Test Course","credits":-1}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_course_create_fail_invalid_credits","message":"Credits '-1' is not valid - must be numeric 0 or larger."} |

    # T33.26.16 #7
    Scenario: Invalid completion grade returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"idnumber":"CRS-1","name":"Test Course","completion_grade":101}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_course_create_fail_invalid_completion_grade","message":"Completion grade '101' is not valid - must be between 0 and 100."} |

    # T33.26.16 #8
    Scenario: Invalid program assignment returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"idnumber":"CRS-1","name":"Test Course","assignment":"bogusprogram"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_course_create_fail_invalid_assignment","message":"Program identified by idnumber 'bogusprogram' is not a valid program."} |

    # T33.26.16 #9
    Scenario: Invalid Moodle Course returns an error.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"idnumber":"CRS-1","name":"Test Course","link":"bogusmoodlecourse"}} |
       Then I should receive from the datahub web service:
         | expected |
         | {"exception":"data_object_exception","errorcode":"ws_course_create_fail_invalid_link","message":"Moodle course identified by shortname 'bogusmoodlecourse' is not a valid Moodle course."} |

    # T33.26.16 #10
    Scenario: Successfully create ELIS Course Description.
       Given I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"idnumber":"CRS-1","name":"Test Course","code":"CRS1","syllabus":"Test","lengthdescription":"Weeks","length":2,"credits":1.1,"completion_grade":50,"cost":"$100","version":"1.0.0","assignment":"PRG-1","link":"MDLCRS-1"}}  |
       Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"course_created","message":"ELIS course description created successfully","record":{"idnumber":"CRS-1","name":"Test Course","code":"CRS1","syllabus":"Test","lengthdescription":"Weeks","length":2,"credits":1.1,"completion_grade":50,"cost":"$100","version":"1.0.0"}} |

    # T33.26.16 #11
    Scenario: Create with invalid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | course | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"idnumber":"CRS-1B","name":"Test Course B","code":"CRS1B","syllabus":"Test B","lengthdescription":"Weeks","length":2,"credits":1.1,"completion_grade":50,"cost":"$100","version":"1.0.1","assignment":"PRG-1","field_custom1":"Option E"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"course_created","message":"ELIS course description created with custom field errors - see logs for details.","record":{"idnumber":"CRS-1B","name":"Test Course B","code":"CRS1B","syllabus":"Test B","lengthdescription":"Weeks","length":2,"credits":1.1,"completion_grade":50,"cost":"$100","version":"1.0.1","field_custom1":"Option 4"}} |

    # T33.26.16 #11.1
    Scenario: Create with valid multi-valued custom field parameters.
        Given the following ELIS custom fields exist:
        | category | name | contextlevel | datatype | control | multi | options | default |
        | cat1 | custom1 | course | text | menu | 1 | Option 1,Option 2,Option 3,Option 4 | Option 4 |
        And I make a datahub webservice request to the "local_datahub_elis_course_create" method with body:
         | body |
         | {"data":{"idnumber":"CRS-1C","name":"Test Course C","code":"CRS1C","syllabus":"Test C","lengthdescription":"Weeks","length":2,"credits":1.1,"completion_grade":50,"cost":"$100","version":"1.0.2","assignment":"PRG-1","field_custom1":"Option 1,Option 2"}} |
        Then I should receive from the datahub web service:
         | expected |
         | {"messagecode":"course_created","message":"ELIS course description created successfully","record":{"idnumber":"CRS-1C","name":"Test Course C","code":"CRS1C","syllabus":"Test C","lengthdescription":"Weeks","length":2,"credits":1.1,"completion_grade":50,"cost":"$100","version":"1.0.2","field_custom1":"Option 1,Option 2"}} |

