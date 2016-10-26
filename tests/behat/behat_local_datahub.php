<?php

require_once(__DIR__.'/../../../../lib/behat/behat_files.php');

use Behat\Behat\Context\Step\Given as Given,
    Behat\Behat\Context\ContextInterface as ContextInterface,
    Behat\Gherkin\Node\PyStringNode as PyStringNode,
    Behat\Gherkin\Node\TableNode as TableNode,
    Behat\Mink\Exception\ExpectationException as ExpectationException,
    Behat\Mink\Exception\DriverException as DriverException,
    Behat\Mink\Exception\ElementNotFoundException as ElementNotFoundException;

class behat_local_datahub extends behat_files implements ContextInterface {
    protected $sent = null;

    /**
     * @Given /^the following ELIS users exist:$/
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
     * @Given /^I make a datahub webservice request to the "(?P<arg1_string>(?:[^"]|\\")*)" method with body:$/
     */
    public function iMakeADatahubWebserviceRequestToTheMethodWithBody($arg1, TableNode $tab) {
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
        $params = '';
        if (!empty($tab)) {
            $data = $tab->getHash();
            foreach ($data as $datarow) {
                $encodedparams = $datarow['body'];
                break;
            }
            if (!empty($encodedparams)) {
                $params = json_decode($encodedparams, true);
                $params = http_build_query($params, '', '&');
            }
        }
        // error_log("\niMakeADatahubWebserviceRequestToTheMethodWithBody:: encodedparams = {$encodedparams}; params = {$params}");

        $curl = new \curl;
        $resp = $curl->post($serverurl->out(false), $params);
        $this->received = $resp;
    }

    /**
     * @Then /^I should receive from the datahub web service:$/
     */
    public function iShouldReceiveFromTheDatahubWebService(TableNode $tab) {
        $str = '';
        if (!empty($tab)) {
            $data = $tab->getHash();
            foreach ($data as $datarow) {
                $str = $datarow['expected'];
                break;
            }
        }
        $received = $this->received;
        // error_log("\niShouldReceiveFromTheDatahubWebService:: exp = {$str}; Rx = {$received}");

        // Remove the dynamic id parameters: curid, courseid, id, userid, classid, trackid, ...
        $received = preg_replace('#\"[a-z]*id\"\:([0-9]{6})[,]*#', '', $received);
        // Remove the dynamic parent userset parameter.
        $received = preg_replace('#\"parent\"\:([0-9]{6})\,#', '', $received);
        // Remove the timestamp parameters that are near impossible to predict.
        $received = preg_replace('#\"[a-z]*time\"\:([0-9]{10})[,]*#', '', $received);
        $received = preg_replace('#\"[a-z]*date\"\:([0-9]{10})[,]*#', '', $received);
        if ($received !== $str) {
            $msg = "Web Service call failed\n";
            $msg .= "Received ".$this->received."\n";
            $msg .= "Expected ".$string."\n";
            throw new \Exception($msg);
        }
    }

    /**
     * Context name to level
     * @param string $contextname context name: user, userset, program, track, class, course, courseset
     * @return int the context level
     */
    public function contextname_2_level($contextname) {
        static $contextlevelmap = ['program' => 11, 'track' => 12, 'course' => 13, 'class' => 14, 'user' => 15, 'userset' => 16, 'courseset' => 17];
        return $contextlevelmap[$contextname];
    }

    /**
     * @Given /^the following ELIS custom fields exist:$/
     */
    public function theFollowingELIScustomfieldsexist(TableNode $table) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/setup.php');
        require_once($CFG->dirroot.'/local/eliscore/lib/data/customfield.class.php');
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $contextlevel = $this->contextname_2_level($datarow['contextlevel']);
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
     * @Given /^the following ELIS programs exist:$/
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
     * @Given /^the following ELIS tracks exist:$/
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
     * @Given /^the following ELIS courses exist:$/
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
     * @Given /^the following ELIS classes exist:$/
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
     * @Given /^the following ELIS usersets exist:$/
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
     * @Given /^the following ELIS program enrolments exist:$/
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
     * @Given /^the following ELIS track enrolments exist:$/
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
     * @Given /^the following ELIS class enrolments exist:$/
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
            $completestatusid = $statusmap[$datarow['completestatus']];
            $ce->completestatusid = $completestatusid;
            if ($completestatusid) {
                $ce->completetime = time();
            }
            $ce->enrolmenttime = strtotime('-1 day');
            $ce->grade = $datarow['grade'];
            $ce->credits = $datarow['credits'];
            $ce->locked = $datarow['locked'];
            $ce->save();
        }
    }

    /**
     * @Given /^the following ELIS userset enrolments exist:$/
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
     * @Given /^I make a Datahub "(?P<arg1_string>(?:[^"]|\\")*)" manual "(?P<arg2_string>(?:[^"]|\\")*)" import with file "(?P<arg3_string>(?:[^"]|\\")*)"$/
     */
    public function iMakeADatahubManualImportWithFile($arg1, $arg2, $arg3) {
        $dhimportpage = '/local/datahub/importplugins/manualrun.php?plugin=dhimport_'.$arg1;
        $this->getSession()->visit($this->locate_path($dhimportpage));
        $this->upload_file_to_filemanager(__DIR__.'/fixtures/'.$arg3, ucwords($arg2).' file');
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
    protected function upload_file_to_filemanager($filepath, $filemanagerelement, TableNode $data = null, $overwriteaction = false) {
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

        if (!empty($data)) {
            // Fill the form in Upload window.
            $datahash = $data->getRowsHash();

            // The action depends on the field type.
            foreach ($datahash as $locator => $value) {

                $field = behat_field_manager::get_form_field_from_label($locator, $this);

                // Delegates to the field class.
                $field->set_value($value);
            }
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
     * @Given /^I make a Datahub "(?P<arg1_string>(?:[^"]|\\")*)" manual export to file "(?P<arg2_string>(?:[^"]|\\")*)"$/
     */
    public function iMakeADatahubManualExportToFile($arg1, $arg2) {
        $dhimportpage = '/local/datahub/exportplugins/manualrun.php?plugin=dhexport_'.$arg1;
        $this->getSession()->visit($this->locate_path($dhimportpage));
        $this->find_button('Run Now')->press();
        // ToDo: click "Save file" in browser dialog?
        // Save/copy file contents to :arg2 ?
    }

    /**
     * @Given /^the Datahub "(?P<arg1_string>(?:[^"]|\\")*)" log file should contain "(?P<arg2_string>(?:[^"]|\\")*)"$/
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
     * @Given /^the Datahub "(?P<arg1_string>(?:[^"]|\\")*)" log file should contain \'(?P<arg2_string>(?:[^\']|\\')*)\'$/
     * Where arg1 is the expected log file prefix: i.e. 'import_version1_manual_course_'
     * and $arg2 is the RegEx expression the last file should contain.
     */
    public function theDatahubLogfileShouldContain2($arg1, $arg2) {
        $this->theDatahubLogfileShouldContain($arg1, $arg2);
    }

    /**
     * @Given /^a "([^"]*)" record with \'([^\']*)\' "([^"]*)" exist$/
     * Given /^a "(?P<arg1_string>(?:[^"]|\\")*)" record with \'?P<arg2_string>(?:[^\']|\\')*)\' "(?P<arg3_string>(?:[^"]|\\")*)" exist$/
     * Note: arg2 json encoded row object for table arg1
     * arg3 = "should" | "should not" ...
     */
    public function aRecordWithExist($arg1, $arg2, $arg3) {
        global $DB;
        if ($DB->record_exists($arg1, (array)json_decode($arg2)) == ($arg3 != "should")) {
            ob_start();
            var_dump($DB->get_records($arg1));
            $tmp = ob_get_contents();
            ob_end_clean();
            error_log("\nTABLE {$arg1} => {$tmp}\n");
            throw new \Exception("Fail: record matching '{$arg2}' in table {$arg1} ".($arg3 == "should" ? 'not ' : '').'found!');
        }
    }

    /**
     * Check checkbox
     * @param string $id base element name.
     */
    public function checkCheckbox($id) {
        $page = $this->getSession()->getPage();
        if (($chkbox = $page->find('xpath', "//input[@id='{$id}']"))) {
            $chkbox->check();
            $chkbox->setValue(true);
        } else {
            throw new \Exception("The expected '{$fullid}' checkbox was not found!");
        }
    }

    /**
     * Click radio
     * @param string $id base element name.
     ^ @param string $val the value to set/click.
     */
    public function clickRadio($id, $val) {
        $page = $this->getSession()->getPage();
        $fullid = "id_{$id}_{$val}";
        $radio = $page->find('xpath', "//input[@id='{$fullid}']");
        if (!empty($radio)) {
            $radio->click();
        } else {
            throw new \Exception("The expected '{$fullid}' radio button was not found!");
        }
    }

    /**
     * Select option.
     * @param string $id base element name.
     * @param string $val the option to select.
     * @param bool $ignoremissing if true no exception for missing element.
     * @return bool true if element found (default), false if not found and $ignoremissing true;
     *         Otherwise throws exception if element not found.
     */
    public function selectOption($id, $val, $ignoremissing = false) {
        $page = $this->getSession()->getPage();
        $sel = $page->find('xpath', "//select[@id='{$id}']");
        if (!empty($sel)) {
            $sel->selectOption($val);
        } else if (!$ignoremissing) {
            throw new \Exception("The expected '{$id}' select element was not found!");
        } else {
            return false;
        }
        return true;
    }

    /**
     * Fillout scheduling date fields: month, day, year, ...
     * @param string $baseid the base element id (prefix) for all components.
     * @param string|object $dateobj ->month, ->day, ->year [, ->hour, ->minute ], or string to strtotime()
     * #return object $dateobj components (i.e. hour, minute for other fields).
     */
    public function filloutScheduleDateField($baseid, $dateobj) {
        $page = $this->getSession()->getPage();
        if (is_string($dateobj)) {
            if (($ts = strtotime($dateobj)) === false) {
                throw new \Exception("Could not parse date string: {$dateobj}");
            }
            // Minute must be on 5 min boundary for UI selector.
            $minute = (int)date('i', $ts);
            $minute -= ($minute % 5);
            if ($minute < 0) {
                $minute = 0;
            }
            $dateobj = (object)[
                'day'    => date('j', $ts),
                'month'  => date('n', $ts),
                'year'   => date('Y', $ts),
                'hour'   => date('G', $ts),
                'minute' => $minute,
            ];
        }
        // Check for enable checkbox.
        $enable = $page->find('xpath', "//input[@id='{$baseid}enabled']");
        if (!empty($enable)) {
            $enable->check();
            $enable->setValue(true);
        }
        foreach ($dateobj as $comp => $val) {
            $this->selectOption("{$baseid}{$comp}", $val, true);
        }
        return $dateobj;
    }

    /**
     * @Given /^the following scheduled Datahub jobs exist:$/
     */
    public function theFollowingScheduledDatahubJobsExist(TableNode $table) {
        $page = $this->getSession()->getPage();
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $plugin = $datarow['plugin'];
            $dhschedpage = '/local/datahub/schedulepage.php?plugin='.$plugin.'&action=list';
            $this->getSession()->visit($this->locate_path($dhschedpage));
            $this->getSession()->wait(self::TIMEOUT * 1000, self::PAGE_READY_JS);
            $this->find_button('New job')->press();
            $this->getSession()->wait(self::TIMEOUT * 1000, self::PAGE_READY_JS);
            // Enter label.
            $page = $this->getSession()->getPage();
            $page->fillField('id_label', $datarow['label']);
            $this->find_button('Next')->press();
            $this->getSession()->wait(self::TIMEOUT * 1000, self::PAGE_READY_JS);
            // Select schedule type: period | advanced (default)
            if ($datarow['type'] == 'period') {
                $this->find_link('Basic Period Scheduling')->click();
                $this->getSession()->wait(self::TIMEOUT * 1000, self::PAGE_READY_JS);
                $page = $this->getSession()->getPage();
                $page->fillField('idperiod', $datarow['params']);
            } else {
                $page = $this->getSession()->getPage();
                $params = json_decode($datarow['params']);
                if (!empty($params->startdate)) {
                    $this->clickRadio('starttype', '1');
                    $dateobj = $this->filloutScheduleDateField('id_startdate_', $params->startdate);
                }
                if (isset($params->recurrence) && $params->recurrence == 'calendar') {
                    $this->clickRadio('recurrencetype', 'calendar');
                    // enddate(enable checkbox), time, days(radio), months.
                    if (!empty($params->enddate)) {
                        $this->filloutScheduleDateField('id_calenddate_', $params->enddate);
                    }
                    if (!empty($dateobj->hour) && empty($params->hour)) {
                        $params->hour = $dateobj->hour;
                    }
                    if (!empty($params->hour)) {
                        $this->selectOption('id_time_hour', $params->hour);
                    }
                    if (!empty($dateobj->minute) && empty($params->minute)) {
                        $params->minute = $dateobj->minute;
                    }
                    if (!empty($params->minute)) {
                        $this->selectOption('id_time_minute', $params->minute);
                    }
                    if (!empty($params->weekdays)) {
                        $this->clickRadio('caldaystype', '1');
                        foreach (explode(',', $params->weekdays) as $day) {
                            $this->checkCheckbox("id_dayofweek_{$day}");
                        }
                    } else if (!empty($params->monthdays)) {
                        $this->clickRadio('caldaystype', '2');
                        $page->fillField('id_monthdays', $params->monthdays);
                    } else {
                        $this->clickRadio('caldaystype', '0');
                    }
                    if (!empty($params->months)) {
                        if ((int)$params->months < 1) {
                            $params->month = date('n');
                        }
                        foreach (explode(',', $params->months) as $month) {
                            $this->checkCheckbox("id_month_{$month}");
                        }
                    } else {
                        $this->checkCheckbox('id_allmonths');
                    }
                } else { // Recurrence simple.
                    if (!empty($params->enddate)) {
                        $this->clickRadio('runtype', '1');
                        $this->filloutScheduleDateField('id_enddate_', $params->enddate);
                    } else if (!empty($params->runs) && !empty($params->frequency) && !empty($params->units)) {
                        $this->clickRadio('runtype', '2');
                        $page->fillField('id_runsremaining', $params->runs);
                        $page->fillField('id_frequency', $params->frequency);
                        $this->selectOption('id_frequencytype', $params->units);
                    }
                }
            }
            $this->find_button('Save')->press();
            if (($cntlink = $this->find_link('Continue'))) {
                $cntlink->click();
            }
        }
    }

    /**
     * @Given /^I wait "(?P<arg1_string>(?:[^"]|\\")*)" minutes and run cron$/
     */
    public function iWaitMinutesAndRunCron($arg1) {
        sleep((int)(60.0 * $arg1));
        set_config('cronclionly', 0);
        $this->getSession()->visit($this->locate_path('/admin/cron.php'));
    }

    /**
     * @Given /^I wait until "(?P<arg1_string>(?:[^"]|\\")*)" and run cron$/
     * @param string $arg1 string to pass to strtotime()
     */
    public function iWaitUntilAndRunCron($arg1) {
        if (($ts = strtotime($arg1)) === false) {
            throw new \Exception("Could not parse date string: {$arg1}");
        }
        sleep($ts - time());
        set_config('cronclionly', 0);
        $this->getSession()->visit($this->locate_path('/admin/cron.php'));
    }

    /**
     * @Given /^I upload file "(?P<arg1_string>(?:[^"]|\\")*)" for "(?P<arg2_string>(?:[^"]|\\")*)" "(?P<arg3_string>(?:[^"]|\\")*)" import$/
     * @param string $arg1 file in ./fixtures/ to copy to dh import area.
     * @param string $arg2 the dhimport_ plugin type: version1 or version1elis
     * @param string $arg3 the type of import file: user, course or enrolment.
     */
    public function iUploadFileForImport($arg1, $arg2, $arg3) {
        global $CFG;
        $fpath = __DIR__.'/fixtures/'.$arg1;
        $dest = $CFG->dataroot.'/'.get_config('dhimport_'.$arg2, 'schedule_files_path');
        @mkdir($dest, 0777, true);
        $dest = $dest.'/'.get_config('dhimport_'.$arg2, $arg3.'_schedule_file');
        if (!copy($fpath, $dest)) {
            throw new \Exception("Failed copying '{$fpath}' to '{$dest}'");
        }
    }

    /**
     * @Then /^the following enrolments should exist:$/
     */
    public function theFollowingEnrolmentsShouldExist(TableNode $table) {
        global $DB;
        $data = $table->getHash();
        foreach ($data as $datarow) {
            if (!is_enrolled(\context_course::instance(
                    $DB->get_field('course', 'id', ['shortname' => $datarow['course']])),
                    $DB->get_field('user', 'id', ['username' => $datarow['user']]))) {
                throw new \Exception("Missing enrolment of {$datarow['user']} in course {$datarow['course']}");
            }
        }
    }

    /**
     * @Then /^the Datahub "(?P<arg1_string>(?:[^"]|\\")*)" export file "(?P<arg2_string>(?:[^"]|\\")*)" contain lines:$/
     * @param string $arg1 version1 or version1elis
     * #param string $arg2 "should" or "should not" ...
     */
    public function theDatahubExportFileShouldContainLines($arg1, $arg2, TableNode $table) {
        global $CFG;
        $exportfilepath = $CFG->dataroot.'/'.get_config('dhexport'.'_'.$arg1, 'export_path').'/'.
                basename(get_config('dhexport'.'_'.$arg1, 'export_file'), '.csv');
        $lasttime = 0;
        $lastfile = null;
        foreach (glob($exportfilepath.'_*.csv') as $exportfile) {
            if ($lasttime < ($newtime = filemtime($exportfile))) {
                $lastfile = $exportfile;
                $lasttime = $newtime;
            }
        }
        $exportfile = $lastfile;
        if (empty($exportfile)) {
            // No export file found!
            throw new \Exception("Export file '{$exportfile}' not found!");
        }
        $contents = file_get_contents($exportfile);
        $data = $table->getHash();
        foreach ($data as $datarow) {
            if (preg_match('|'.$datarow['line'].'|', $contents) != ($arg2 == 'should')) {
                // No matching line found!
                throw new \Exception('Matching line '.(($arg2 == 'should') ? 'not ' :'').
                        "found in export file {$exportfile} to '{$datarow['line']}' in {$contents}");
            }
        }
    }

    /**
     * @Given /^I visit Moodle course "(?P<arg1_string>(?:[^"]|\\")*)"$/
     * @param string $arg1 course shortname
     */
    public function iVisitMoodleCourse($arg1) {
        global $DB;
        $crsid = $DB->get_field('course', 'id', ['shortname' => $arg1]);
        if (empty($crsid)) {
            throw new \Exception("Moodle Course with shortname '{$arg1}' not found!");
        }
        $this->getSession()->visit($this->locate_path("/course/view.php?id={$crsid}"));
    }

    /**
     * @Given /^I update the timemodified for:$/
     */
    public function iUpdateTheTimemodifiedFor(TableNode $table) {
        global $DB;
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $crsid = $DB->get_field('course', 'id', ['shortname' => $datarow['gradeitem']]);
            if (empty($crsid)) {
                $giid = $DB->get_field('grade_items', 'id', ['itemname' => $datarow['gradeitem']]);
            } else {
                $giid = $DB->get_field('grade_items', 'id', ['itemtype' => 'course', 'courseid' => $crsid]);
            }
            if (empty($giid)) {
                throw new \Exception("No course or grade item found matching {$datarow['gradeitem']}");
            }
            $DB->execute('UPDATE {grade_grades} SET timemodified = '.time().' WHERE itemid = '.$giid);
        }
    }

    /**
     * Select version1 export field and optionally set export name.
     * @param object $fieldrec the user_info_field record.
     * @param string $exportname optional name for column in export.
     */
    public function select_version1_exportfield($fieldrec, $exportname = '') {
        $page = $this->getSession()->getPage();
        $sel = $page->find('xpath', '//select[@name="field"]');
        if (!empty($sel)) {
            $sel->selectOption($fieldrec->id);
        } else {
            throw new \Exception("The expected select element 'field' was not found!");
        }
        $this->getSession()->wait(self::TIMEOUT * 1000, self::PAGE_READY_JS);
        if (!empty($exportname)) {
            $page = $this->getSession()->getPage();
            $colname = $page->find('xpath', "//input[@value='{$fieldrec->name}']");
            if (!empty($colname)) {
                $colname->setValue($exportname);
            } else {
                throw new \Exception("The expected text input for fieldname={$fieldrec->name} was not found!");
            }
        }
    }

    /**
     * @Given /^I add the following fields for version1 export:$/
     * Required table column 'field' for field shortname,
     * optional column 'export' for string to usse in export file heading.
     */
    public function iAddTheFollowingFieldsForVersion1Export(TableNode $table) {
        global $DB;
        $this->getSession()->visit($this->locate_path('/local/datahub/exportplugins/version1/config_fields.php'));
        $this->getSession()->wait(self::TIMEOUT * 1000, self::PAGE_READY_JS);
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $fieldrec = $DB->get_record('user_info_field', ['shortname' => $datarow['field']]);
            if (empty($fieldrec)) {
                throw new \Exception("The expected option for field={$datarow['field']} was not found!");
            }
            $this->select_version1_exportfield($fieldrec, isset($datarow['export']) ? $datarow['export'] : '');
        }
        $this->find_button('Save changes')->press();
    }

    /**
     * Select version1 export field and optionally set export name.
     * @param string $clevel the context level.
     * @param int $fieldid the field id.
     * @param string $exportname optional name for column in export.
     */
    public function select_version1elis_exportfield($clevel, $fieldid, $exportname = '') {
        $page = $this->getSession()->getPage();
        $fset = $page->find('xpath', "//li[@data-fieldset='{$clevel}']");
        if (!empty($fset)) {
            $fset->click();
        } else {
            throw new \Exception("The expected '{$clevel}' fieldset was not found!");
        }
        $generalcontext = behat_context_helper::get('behat_general');
        $generalcontext->i_drag_and_i_drop_it_in("//li[@data-field='{$fieldid}']", 'xpath_element',
                '//div[@class="active_fields"]/ul[@class="fieldlist ui-sortable"]', 'xpath_element');
        if (!empty($exportname)) {
            $this->getSession()->wait(self::TIMEOUT * 1000);
            $page = $this->getSession()->getPage(); // Update page?
            $colenable = $page->find('xpath', "//li[@data-field='{$fieldid}']/a[@class='rename']");
            if (!empty($colenable)) {
                $colenable->click();
            } else {
                throw new \Exception("The expected link to rename fieldid={$fieldid} column was not found!");
            }
            $colname = $page->find('xpath', "//li[@data-field='{$fieldid}']/input[@class='fieldname_textbox']");
            if (!empty($colname)) {
                $colname->setValue($exportname);
            } else {
                throw new \Exception("The expected text input for fieldid={$fieldid} column was not found!");
            }
        }
    }

    /**
     * @Given /^I add the following fields for version1elis export:$/
     * Required table columns 'contextlevel' (user,class,course,program,...), 'field' for field shortname,
     * optional column 'export' for string to usse in export file heading.
     */
    public function iAddTheFollowingFieldsForVersion1ElisExport(TableNode $table) {
        global $DB;
        $this->getSession()->visit($this->locate_path('/local/datahub/exportplugins/version1elis/config_fields.php'));
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $fieldid = false;
            if ($datarow['contextlevel'] != 'student') {
                $clevel = $this->contextname_2_level($datarow['contextlevel']);
                $sql = 'SELECT fld.id
                          FROM {local_eliscore_field} fld
                          JOIN {local_eliscore_field_clevels} cl ON fld.id = cl.fieldid
                               AND cl.contextlevel = ?
                         WHERE fld.shortname = ?';
                $fieldid = $DB->get_field_sql($sql, [$clevel, $datarow['field']]);
            }
            $fieldid = empty($fieldid) ? $datarow['field'] : "field_{$fieldid}";
            $this->select_version1elis_exportfield($datarow['contextlevel'], $fieldid, isset($datarow['export']) ? $datarow['export'] : '');
        }
        $this->find_button('Save changes')->press();
    }

    /**
     * @Given /^I map the following fields for "(?P<arg1_string>(?:[^"]|\\")*)" "(?P<arg2_string>(?:[^"]|\\")*)" import:$/
     * @param string $arg1 plugin either: version1 or version1elis
     * @param string $arg2 import type: user, course or enrolment
     * Required table columns: 'field' , 'column' (in import file)
     */
    public function iMapTheFollowingFieldsForImport($arg1, $arg2, TableNode $table) {
        global $DB;
        $this->getSession()->visit($this->locate_path('/local/datahub/importplugins/'.$arg1.'/config_fields.php?tab='.$arg2));
        $page = $this->getSession()->getPage();
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $page->fillField('id_'.$datarow['field'], $datarow['column']);
        }
        $this->find_button('Save changes')->press();
    }

    /**
     * @Given /^the following Moodle user profile fields exist:$/
     */
    public function theFollowingMoodleUserProfileFieldsExist(TableNode $table) {
        global $DB;
        $data = $table->getHash();
        foreach ($data as $datarow) {
            $cat = new \stdClass;
            $cat->name = $datarow['category'];
            if (!($catid = $DB->get_field('user_info_category', 'id', ['name' => $cat->name]))) {
                $catid = $DB->insert_record('user_info_category', $cat);
            }
            $rec = new \stdClass;
            $rec->categoryid = $catid;
            $rec->shortname = $datarow['name'];
            $rec->name = $datarow['name'];
            $rec->datatype = $datarow['type'];
            $rec->defaultdata = $datarow['default'];
            $rec->param1 = str_replace(',', "\n", $datarow['options']);
            $DB->insert_record('user_info_field', $rec);
        }
    }
}
