<?php

require_once(__DIR__.'/../../../../lib/behat/behat_base.php');

use Behat\Behat\Context\Step\Given as Given,
    Behat\Behat\Context\SnippetAcceptingContext,
    Behat\Gherkin\Node\PyStringNode as PyStringNode,
    Behat\Gherkin\Node\TableNode as TableNode,
    Behat\Mink\Exception\ExpectationException as ExpectationException,
    Behat\Mink\Exception\DriverException as DriverException,
    Behat\Mink\Exception\ElementNotFoundException as ElementNotFoundException;

class behat_local_datahub extends behat_base implements SnippetAcceptingContext {
    protected $sent = null;

    /**
     * @Given the following ELIS users exist
     */
    public function theFollowingElisUsersExist(TableNode $table) {
        global $CFG;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/user.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $user = new user();
            $user->idnumber = $datarow['idnumber'];
            $user->username = $datarow['username'];
            $user->email = $datarow['idnumber'].'@example.com';
            $user->firstname = 'Student';
            $user->lastname = 'Test';
            $user->save();
        }
    }

    /**
     * @Given I make a datahub webservice request to the :arg1 method with body:
     */
    public function iMakeADatahubWebserviceRequestToTheMethodWithBody($arg1, PyStringNode $string) {
        require_once(__DIR__.'/../../../../lib/filelib.php');
        global $DB;

        $record = [
            'token' => 'f4348c193310b549d8db493750eb4967',
            'tokentype' => '0',
            'userid' => 2,
            'externalserviceid' => 2,
            'contextid' => 1,
            'creatorid' => 2,
            'validuntil' => 0,
            'timecreated' => 12345,
        ];
        $DB->insert_record('external_tokens', (object)$record);
        $token = 'f4348c193310b549d8db493750eb4967';
        $method = $arg1;
        $urlparams = [
            'wstoken' => $token,
            'wsfunction' => $method,
            'moodlewsrestformat' => 'json',
        ];
        $serverurl = new \moodle_url('/webservice/rest/server.php', $urlparams);

        $params = $string->getRaw();
        if (!empty($params)) {
            $params = json_decode($string->getRaw(), true);
            $params = http_build_query($params, '', '&');
        }

        $curl = new \curl;
        $resp = $curl->post($serverurl->out(false), $params);
        $this->received = $resp;
    }

    /**
     * @Then I should receive from the datahub web service:
     */
    public function iShouldReceiveFromTheDatahubWebService(PyStringNode $string) {
        $string = $string->getRaw();
        // Remove the dynamic id parameters: curid, courseid, id, userid, classid, trackid, ...
        $this->received = preg_replace('#\"[a-z]*id\"\:([0-9]{6})[,]*#', '', $this->received);
        // Remove the dynamic parent userset parameter.
        $this->received = preg_replace('#\"parent\"\:([0-9]{6})\,#', '', $this->received);
        // Remove the timestamp parameters that are near impossible to predict.
        $this->received = preg_replace('#\"[a-z]*time\"\:([0-9]{10})[,]*#', '', $this->received);
        $this->received = preg_replace('#\"[a-z]*date\"\:([0-9]{10})[,]*#', '', $this->received);
        if ($this->received !== $string) {
            $msg = "Web Service call failed\n";
            $msg .= "Received ".$this->received."\n";
            $msg .= "Expected ".$string."\n";
            throw new \Exception($msg);
        }
    }

    /**
     * @Given the following ELIS custom fields exist
     */
    public function theFollowingELIScustomfieldsexist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/setup.php');
        require_once($CFG->dirroot.'/local/eliscore/lib/data/customfield.class.php');
        static $contextlevelmap = ['program' => 11, 'track' => 12, 'course' => 13, 'class' => 14, 'user' => 15, 'userset' => 16, 'courseset' => 17];
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $contextlevel = $contextlevelmap[$datarow['contextlevel']];
            $catobj = field_category::ensure_exists_for_contextlevel($datarow['category'], $contextlevel);
            $fieldrec = [
                'shortname' => $datarow['name'],
                'name' => $datarow['name'],
                'datatype' => $datarow['datatype'],
                'description' => '',
                'categoryid' => $catobj->id,
                'sortorder' => 0,
                'multivalued' => $datarow['multi'],
                'forceunique' => 0,
                // 'params' => 'a:0:{}',
            ];
            $fieldobj = field::ensure_field_exists_for_context_level(new field($fieldrec), $contextlevel, $catobj);

            $ownerrec = [
                'required' => 0,
                'edit_capability' => '',
                'view_capability' => '',
                'control' => $datarow['control'],
                'options_source' => '',
                'options' => str_replace(',', "\n", $datarow['options']),
                'columns' => 30,
                'rows' => 10,
                'maxlength' => 2048,
                'startyear' => 1970,
                'stopyear' => 2038,
                'inctime' => '0',
            ];
            field_owner::ensure_field_owner_exists($fieldobj, 'manual', $ownerrec);

            // Insert a default value for the field:
            if (!empty($datarow['default'])) {
                field_data::set_for_context_and_field(null, $fieldobj, empty($datarow['multi']) ? $datarow['default'] : [$datarow['default']]);
            }
        }
    }

    /**
     * @Given the following ELIS programs exist
     */
    public function theFollowingElisProgramsExist(TableNode $table) {
        global $CFG;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/curriculum.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $pgm = new curriculum();
            $pgm->idnumber = $datarow['idnumber'];
            $pgm->name = $datarow['name'];
            $pgm->description = 'Description of the Program';
            $pgm->reqcredits = $datarow['reqcredits'];
            $pgm->save();
        }
    }

    /**
     * @Given the following ELIS tracks exist
     */
    public function theFollowingElisTracksExist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/track.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $trk = new track();
            $trk->curid = $DB->get_field(curriculum::TABLE, 'id', ['idnumber' => $datarow['program_idnumber']]);
            $trk->idnumber = $datarow['idnumber'];
            $trk->name = $datarow['name'];
            $trk->description = 'Description of the Track';
            $trk->save();
        }
    }

    /**
     * @Given the following ELIS courses exist
     */
    public function theFollowingElisCoursesExist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/course.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $crs = new course();
            $crs->idnumber = $datarow['idnumber'];
            $crs->name = $datarow['name'];
            $crs->credits = $datarow['credits'];
            $crs->completion_grade = $datarow['completion_grade'];
            $crs->syllabus = 'Description of the Course';
            $crs->save();
        }
    }

    /**
     * @Given the following ELIS classes exist
     */
    public function theFollowingElisClassesExist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/pmclass.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $cls = new pmclass();
            $cls->idnumber = $datarow['idnumber'];
            $cls->courseid = $DB->get_field(course::TABLE, 'id', ['idnumber' => $datarow['course_idnumber']]);
            $cls->save();
        }
    }

    /**
     * @Given the following ELIS usersets exist
     */
    public function theFollowingElisUsersetsExist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/userset.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $us = new userset();
            $us->name = $datarow['name'];
            $us->display = $datarow['name'];
            $us->parent = ($datarow['parent_name'] == 'top') ? 0 : $DB->get_field(userset::TABLE, 'id', ['name' => $datarow['parent_name']]);
            $us->save();
        }
    }

    /**
     * @Given the following ELIS program enrolments exist
     */
    public function theFollowingElisProgramEnrolmentsExist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/curriculumstudent.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $cs = new curriculumstudent();
            $cs->userid = $DB->get_field(user::TABLE, 'id', ['idnumber' => $datarow['user_idnumber']]);
            $cs->curriculumid = $DB->get_field(curriculum::TABLE, 'id', ['idnumber' => $datarow['program_idnumber']]);
            $cs->save();
        }
    }

    /**
     * @Given the following ELIS track enrolments exist
     */
    public function theFollowingElisTrackEnrolmentsExist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/usertrack.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $ut = new usertrack();
            $ut->userid = $DB->get_field(user::TABLE, 'id', ['idnumber' => $datarow['user_idnumber']]);
            $ut->trackid = $DB->get_field(track::TABLE, 'id', ['idnumber' => $datarow['track_idnumber']]);
            $ut->save();
        }
    }

    /**
     * @Given the following ELIS class enrolments exist
     */
    public function theFollowingElisClassEnrolmentsExist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/student.class.php');
        static $statusmap = ['notcompleted' => 0, 'failed' => 1, 'passed' => 2];
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $ce = new student();
            $ce->userid = $DB->get_field(user::TABLE, 'id', ['idnumber' => $datarow['user_idnumber']]);
            $ce->classid = $DB->get_field(pmclass::TABLE, 'id', ['idnumber' => $datarow['class_idnumber']]);
            $ce->completestatusid = $statusmap[$datarow['completestatus']];
            $ce->grade = $datarow['grade'];
            $ce->credits = $datarow['credits'];
            $ce->locked = $datarow['locked'];
            $ce->save();
        }
    }

    /**
     * @Given the following ELIS userset enrolments exist
     */
    public function theFollowingElisUsersetEnrolmentsExist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/data/clusterassignment.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $ca = new clusterassignment();
            $ca->userid = $DB->get_field(user::TABLE, 'id', ['idnumber' => $datarow['user_idnumber']]);
            $ca->clusterid = $DB->get_field(userset::TABLE, 'id', ['name' => $datarow['userset_name']]);
            $ca->plugin = $datarow['plugin'];;
            $ca->save();
        }
    }
}
