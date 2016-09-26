<?php

require_once(__DIR__.'/../../../../lib/behat/behat_files.php');

use Behat\Behat\Context\Step\Given as Given,
    Behat\Behat\Context\SnippetAcceptingContext,
    Behat\Gherkin\Node\PyStringNode as PyStringNode,
    Behat\Gherkin\Node\TableNode as TableNode,
    Behat\Mink\Exception\ExpectationException as ExpectationException,
    Behat\Mink\Exception\DriverException as DriverException,
    Behat\Mink\Exception\ElementNotFoundException as ElementNotFoundException;

class behat_local_datahub extends behat_files implements SnippetAcceptingContext {
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

    /**
     * @Given I make a Datahub :arg1 manual :arg2 import with file :arg3
     */
    public function iMakeADatahubManualImportWithFile($arg1, $arg2, $arg3) {
        $dhimportpage = '/local/datahub/importplugins/manualrun.php?plugin=dhimport_'.$arg1;
        $this->getSession()->visit($this->locate_path($dhimportpage));
        $this->upload_file_to_filemanager(__DIR__.'/fixtures/'.$arg3, ucwords($arg2).' file', new TableNode([]), false);
        $this->find_button('Run Now')->press();
    }

    /**
     * Uploads a file to filemanager
     * @see: repository/upload/tests/behat/behat_repository_upload.php
     *
     * @throws ExpectationException Thrown by behat_base::find
     * @param string $filepath Normally a path relative to $CFG->dirroot, but can be an absolute path too.
     * @param string $filemanagerelement
     * @param TableNode $data Data to fill in upload form
     * @param false|string $overwriteaction false if we don't expect that file with the same name already exists,
     *     or button text in overwrite dialogue ("Overwrite", "Rename to ...", "Cancel")
     */
    protected function upload_file_to_filemanager($filepath, $filemanagerelement, TableNode $data, $overwriteaction = false) {
        global $CFG;

        $filemanagernode = $this->get_filepicker_node($filemanagerelement);

        // Opening the select repository window and selecting the upload repository.
        $this->open_add_file_window($filemanagernode, get_string('pluginname', 'repository_upload'));

        // Ensure all the form is ready.
        $noformexception = new ExpectationException('The upload file form is not ready', $this->getSession());
        $this->find(
            'xpath',
            "//div[contains(concat(' ', normalize-space(@class), ' '), ' file-picker ')]".
                "[contains(concat(' ', normalize-space(@class), ' '), ' repository_upload ')]".
                "/descendant::div[@class='fp-content']".
                "/descendant::div[contains(concat(' ', normalize-space(@class), ' '), ' fp-upload-form ')]".
                "/descendant::form",
            $noformexception
        );
        // After this we have the elements we want to interact with.

        // Form elements to interact with.
        $file = $this->find_file('repo_upload_file');

        // Attaching specified file to the node.
        // Replace 'admin/' if it is in start of path with $CFG->admin .
        if (substr($filepath, 0, 6) === 'admin/') {
            $filepath = $CFG->dirroot.DIRECTORY_SEPARATOR.$CFG->admin.
                    DIRECTORY_SEPARATOR.substr($filepath, 6);
        }
        $filepath = str_replace('/', DIRECTORY_SEPARATOR, $filepath);
        if (!is_readable($filepath)) {
            $filepath = $CFG->dirroot.DIRECTORY_SEPARATOR.$filepath;
            if (!is_readable($filepath)) {
                throw new ExpectationException('The file to be uploaded does not exist.', $this->getSession());
            }
        }
        $file->attachFile($filepath);

        // Fill the form in Upload window.
        $datahash = $data->getRowsHash();

        // The action depends on the field type.
        foreach ($datahash as $locator => $value) {

            $field = behat_field_manager::get_form_field_from_label($locator, $this);

            // Delegates to the field class.
            $field->set_value($value);
        }

        // Submit the file.
        $submit = $this->find_button(get_string('upload', 'repository'));
        $submit->press();

        // We wait for all the JS to finish as it is performing an action.
        $this->getSession()->wait(self::TIMEOUT, self::PAGE_READY_JS);

        if ($overwriteaction !== false) {
            $overwritebutton = $this->find_button($overwriteaction);
            $this->ensure_node_is_visible($overwritebutton);
            $overwritebutton->click();

            // We wait for all the JS to finish.
            $this->getSession()->wait(self::TIMEOUT, self::PAGE_READY_JS);
        }

    }

    /**
     * @Given I make a Datahub :arg1 manual export to file :arg2
     */
    public function iMakeADatahubManualExportToFile($arg1, $arg2) {
        $dhimportpage = '/local/datahub/exportplugins/manualrun.php?plugin=dhexport_'.$arg1;
        $this->getSession()->visit($this->locate_path($dhimportpage));
        $this->find_button('Run Now')->press();
        // ToDo: click "Save file" in browser dialog?
        // Save/copy file contents to :arg2 ?
    }

    /**
     * @Given The Datahub :arg1 log file should contain :arg2
     * Where arg1 is the expected log file prefix: i.e. 'import_version1_manual_course_'
     * and $arg2 is the RegEx expression the last file should contain.
     */
    public function theDatahubLogfileShouldContain($arg1, $arg2) {
        global $CFG;
        $parts = explode('_', $arg1);
        $logfilepath = $CFG->dataroot.'/'.get_config('dh'.$parts[0].'_'.$parts[1], 'logfilelocation').'/'.$arg1;
        $lasttime = 0;
        $lastfile = null;
        foreach (glob($logfilepath.'*.log') as $logfile) {
            if ($lasttime < ($newtime = filemtime($logfile))) {
                $lastfile = $logfile;
                $lasttime = $newtime;
            }
        }
        if (empty($lastfile)) {
            // No log file found!
            throw new \Exception('No log file found with prefix: '.$logfilepath);
        }
        $contents = file_get_contents($lastfile);
        if (!preg_match('|'.$arg2.'|', $contents)) {
            // No match found!
            throw new \Exception("No matching lines in log file {$lastfile} to '{$arg2}' in {$contents}");
        }
    }

    /**
     * @Given a :arg1 record with :arg2 :arg3 exist
     * Note: arg2 json encoded row object for table arg1
     * arg3 = "should" | "should not" ...
     */
    public function aRecordWithExist($arg1, $arg2, $arg3) {
        global $DB;
        if ($DB->record_exists($arg1, (array)json_decode($arg2)) == ($arg3 != "should")) {
            throw new \Exception("Fail: record matching '{$arg2}' in table {$arg1} ".($arg3 == "should" ? 'not ' : '').'found!');
        }
    }
}
