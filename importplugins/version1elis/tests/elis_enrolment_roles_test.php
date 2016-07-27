<?php
/**
 * ELIS(TM): Enterprise Learning Intelligence Suite
 * Copyright (C) 2008-2016 Remote-Learner.net Inc (http://www.remote-learner.net)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * @package    dhimport_version1elis
 * @author     Remote-Learner.net Inc
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 * @copyright  (C) 2008-2016 Remote Learner.net Inc http://www.remote-learner.net
 *
 */

require_once(dirname(__FILE__).'/../../../../../local/eliscore/test_config.php');
global $CFG;
require_once($CFG->dirroot.'/local/datahub/tests/other/rlip_test.class.php');

// Libs.
require_once(dirname(__FILE__).'/other/rlip_mock_provider.class.php');
require_once($CFG->dirroot.'/local/datahub/lib.php');
require_once($CFG->dirroot.'/local/datahub/lib/rlip_fileplugin.class.php');

/**
 * Test enrolment role assign/unassign.
 * @group local_datahub
 * @group dhimport_version1elis
 */
class version1elisenrolmentroles_testcase extends rlip_elis_test {

    /**
     * Called before the class.
     */
    public static function setUpBeforeClass() {
        parent::setUpBeforeClass();
        static::get_csv_files();
        static::get_logfilelocation_files();
        static::get_zip_files();
    }

    /**
     * Validates that the supplied data produces the expected error
     *
     * @param array $data The import data to process
     * @param string $expectederror The error we are expecting (message only)
     * @param user $entitytype One of 'user', 'course', 'enrolment'
     */
    protected function assert_data_produces_error($data, $expectederror, $entitytype) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/datahub/lib/rlip_fileplugin.class.php');
        require_once($CFG->dirroot.'/local/datahub/lib/rlip_dataplugin.class.php');

        // Set the log file location.
        $filepath = $CFG->dataroot.RLIP_DEFAULT_LOG_PATH;
        self::cleanup_log_files();

        // Run the import.
        $classname = "rlipimport_version1elis_importprovider_fslog{$entitytype}";
        $provider = new $classname($data);
        $instance = rlip_dataplugin_factory::factory('dhimport_version1elis', $provider, null, true);
        // Suppress output for now.
        ob_start();
        $instance->run();
        ob_end_clean();

        // Validate that a log file was created.
        $manual = true;
        // Get first summary record - at times, multiple summary records are created and this handles that problem.
        $records = $DB->get_records(RLIP_LOG_TABLE, null, 'starttime DESC');
        foreach ($records as $record) {
            $starttime = $record->starttime;
            break;
        }

        // Get logfile name.
        $plugintype = 'import';
        $plugin = 'dhimport_version1elis';
        $format = get_string('logfile_timestamp', 'local_datahub');
        $testfilename = $filepath.'/'.$plugintype.'_version1elis_manual_'.$entitytype.'_'.userdate($starttime, $format).'.log';
        // Get most recent logfile.

        $filename = self::get_current_logfile($testfilename);
        if (!file_exists($filename)) {
            echo "\n can't find logfile: $filename for \n$testfilename";
        }
        $this->assertTrue(file_exists($filename));

        // Fetch log line.
        $pointer = fopen($filename, 'r');

        $prefixlength = strlen('[MMM/DD/YYYY:hh:mm:ss -zzzz] ');

        while (!feof($pointer)) {
            $error = fgets($pointer);
            if (!empty($error)) { // Could be an empty new line.
                if (is_array($expectederror)) {
                    $actualerror[] = substr($error, $prefixlength);
                } else {
                    $actualerror = substr($error, $prefixlength);
                }
            }
        }

        fclose($pointer);

        $this->assertEquals($expectederror, $actualerror);
    }

    /**
     * Main data provider for test_enrolmentroleactions
     * Format of data: [role-params, role-assignments, elisentity-params, dhimport-params, expected-results]
     * E.g. of single call:
     * 'Eg' => [
     *     'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM]],
     *     'elis' => [['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
     *         'email' => 'egemail@noreply.com']],
     *             ['curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']],
     *             ['track' => [['idnumber' => 'trk1id', 'name' => 'trk1_name', 'curid' => '?prg1id']], ...]
     *     'role_assign' => ['user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => ...]
     *     'importrecord' => ['action' => 'assign', 'context' => 'track_1', 'user_username' => 'egusername', 'role' => 'role_shortname'],
     *     'expected' => ['message' => 'Actual errors message', 'user_idnumber' => ?, 'role_shortname' => ?, 'role_context' => ?]
     * ]
     */
    public function enrolmentroleactions_dataprovider() {
        return [
            'test1' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM]],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'curriculum_prg1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] Specified role "role_shortname" not assignable on specified context "curriculum_prg1id".
']
            ],
            'test2' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_PROGRAM']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'curriculum_prg1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully assigned role "role_shortname" on context "curriculum_prg1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\program:prg1id']
            ],
            'test3' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_PROGRAM']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']]],
                'role_assign' => [['user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname',
                        'role_context' => '\\local_elisprogram\\context\\program:prg1id']],
                'importrecord' => ['action' => 'unassign', 'context' => 'curriculum_prg1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully unassigned role "role_shortname" on context "curriculum_prg1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\program:prg1id']
            ],
            'test4' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM]],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'curriculum_prg1id', 'user_username' => 'bogususer', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] Specified ELIS user not found.
']
            ],
            'test5' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM]],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'bogusXXX_prg1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] Enrolment could not be assignd.
']
            ],
            'test6' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM]],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'curriculum_bogusXXX', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] Invalid ELIS context instance "curriculum_bogusXXX" specified.
']
            ],
            'test7' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM]],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'curriculum_prg1id', 'user_username' => 'egusername', 'role' => 'role_bogus'],
                'expected' => ['message' => '[enrolment.csv line 2] Invalid role shortname "role_bogus" specified.
']
            ],
            'test8' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_PROGRAM']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'unassign', 'context' => 'curriculum_prg1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully unassigned role "role_shortname" on context "curriculum_prg1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\program:prg1id']
            ],
            'test9' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_COURSE']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'course' => [['idnumber' => 'crs1id', 'name' => 'crs1 name', 'syllabus' => '*']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'course_crs1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully assigned role "role_shortname" on context "course_crs1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\course:crs1id']
            ],
            'test10' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_COURSE']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'course' => [['idnumber' => 'crs1id', 'name' => 'crs1 name', 'syllabus' => '*']]],
                'role_assign' => [['user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname',
                        'role_context' => '\\local_elisprogram\\context\\course:crs1id']],
                'importrecord' => ['action' => 'unassign', 'context' => 'course_crs1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully unassigned role "role_shortname" on context "course_crs1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\course:crs1id']
            ],
            'test11' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_CLASS']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'course' => [['idnumber' => 'crs1id', 'name' => 'crs1 name', 'syllabus' => '*']],
                    'pmclass' => [['idnumber' => 'cls1id', 'name' => 'cls1 name', 'courseid' => '?crs1id']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'class_cls1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully assigned role "role_shortname" on context "class_cls1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\pmclass:cls1id']
            ],
            'test12' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_CLASS']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'course' => [['idnumber' => 'crs1id', 'name' => 'crs1 name', 'syllabus' => '*']],
                    'pmclass' => [['idnumber' => 'cls1id', 'name' => 'cls1 name', 'courseid' => '?crs1id']]],
                'role_assign' => [['user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname',
                        'role_context' => '\\local_elisprogram\\context\\pmclass:cls1id']],
                'importrecord' => ['action' => 'unassign', 'context' => 'class_cls1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully unassigned role "role_shortname" on context "class_cls1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\pmclass:cls1id']
            ],
            'test13' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_TRACK']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']],
                    'track' => [['idnumber' => 'trk1id', 'name' => 'trk1 name', 'curid' => '?prg1id']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'track_trk1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully assigned role "role_shortname" on context "track_trk1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\track:trk1id']
            ],
            'test14' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_TRACK']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'curriculum' => [['idnumber' => 'prg1id', 'name' => 'prg1 name']],
                    'track' => [['idnumber' => 'trk1id', 'name' => 'trk1 name', 'curid' => '?prg1id']]],
                'role_assign' => [['user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname',
                        'role_context' => '\\local_elisprogram\\context\\track:trk1id']],
                'importrecord' => ['action' => 'unassign', 'context' => 'track_trk1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully unassigned role "role_shortname" on context "track_trk1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\program:prg1id']
            ],
            'test15' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_USER']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com'],
                        ['username' => 'username2', 'idnumber' => 'idnumber2', 'firstname' => 'First', 'lastname' => 'Last2',
                        'email' => 'email2@noreply.com']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'user_idnumber2', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully assigned role "role_shortname" on context "user_idnumber2".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\user:idnumber2']
            ],
            'test16' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_USER']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com'],
                        ['username' => 'username2', 'idnumber' => 'idnumber2', 'firstname' => 'First', 'lastname' => 'Last2',
                        'email' => 'email2@noreply.com']]],
                'role_assign' => [['user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname',
                        'role_context' => '\\local_elisprogram\\context\\user:idnumber2']],
                'importrecord' => ['action' => 'unassign', 'context' => 'user_idnumber2', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully unassigned role "role_shortname" on context "user_idnumber2".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\user:idnumber2']
            ],
            'test17' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_USERSET']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'userset' => [['idnumber' => 'us1id', 'name' => 'us1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'cluster_us1 name', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully assigned role "role_shortname" on context "cluster_us1 name".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\userset:us1id']
            ],
            'test18' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_USERSET']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'userset' => [['idnumber' => 'us1id', 'name' => 'us1 name']]],
                'role_assign' => [['user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname',
                        'role_context' => '\\local_elisprogram\\context\\userset:us1id']],
                'importrecord' => ['action' => 'unassign', 'context' => 'cluster_us1 name', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully unassigned role "role_shortname" on context "cluster_us1 name".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\userset:us1id']
            ],
            'test19' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_COURSESET']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'courseset' => [['idnumber' => 'cs1id', 'name' => 'cs1 name']]],
                'role_assign' => null,
                'importrecord' => ['action' => 'assign', 'context' => 'courseset_cs1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully assigned role "role_shortname" on context "courseset_cs1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\courseset:cs1id']
            ],
            'test20' => [
                'role' => ['shortname' => 'role_shortname', 'name' => 'role_name', 'contextlevels' => [CONTEXT_SYSTEM, 'CONTEXT_ELIS_COURSESET']],
                'elis' => ['user' => [['username' => 'egusername', 'idnumber' => 'egidnumber', 'firstname' => 'First', 'lastname' => 'Last',
                        'email' => 'egemail@noreply.com']],
                    'courseset' => [['idnumber' => 'cs1id', 'name' => 'cs1 name']]],
                'role_assign' => [['user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname',
                        'role_context' => '\\local_elisprogram\\context\\courseset:cs1id']],
                'importrecord' => ['action' => 'unassign', 'context' => 'courseset_cs1id', 'user_username' => 'egusername', 'role' => 'role_shortname'],
                'expected' => ['message' => '[enrolment.csv line 2] User with username "egusername" successfully unassigned role "role_shortname" on context "courseset_cs1id".
',
                    'user_idnumber' => 'egidnumber', 'role_shortname' => 'role_shortname', 'role_context' => '\\local_elisprogram\\context\\courseset:cs1id']
            ],
        ];
    }

    /**
     * Private method to create ELIS entities.
     * @param string $entity ELIS class to create.
     * @param array $data The object initialization data.
     * @return object the ELIS instance.
     */
    private static function create_entity($entity, $data) {
        if ($entity == 'userset' && isset($data['idnumber'])) {
            unset($data['idnumber']);
        }
        return new $entity($data);
    }

    /**
     * Validate log message for an invalid action value for user enrolments
     * @dataProvider enrolmentroleactions_dataprovider
     * @param array $role role setup parameters.
     * @param array $elisentities ELIS entities required for test.
     * @param mixed $roleassign role assignment parameters.
     * @param array $record The datahub record to process.
     * @param array $expected The expected test result to compare with.
     */
    public function test_enrolmentroleactions($role, $elisentities, $roleassign, $record, $expected) {
        global $CFG, $DB;
        require_once($CFG->dirroot.'/local/elisprogram/lib/setup.php');

        if (!empty($role)) {
            $roleid = create_role($role['name'], $role['shortname'], 'Role description');
            allow_assign($roleid, $roleid);
            if (!empty($role['contextlevels'])) {
                foreach ($role['contextlevels'] as $key => $level) {
                    $role['contextlevels'][$key] = is_int($level) ? $level : constant($level);
                }
                set_role_contextlevels($roleid, $role['contextlevels']);
            }
        }

        $objs = [];
        if (!empty($elisentities)) {
            foreach ($elisentities as $entity => $instances) {
                foreach ($instances as $data) {
                    foreach ($data as $param => $val) {
                        if (strpos($val, '?') === 0) {
                            $data[$param] = $objs[substr($val, 1)];
                        }
                    }
                    $obj = self::create_entity($entity, $data);
                    $obj->save();
                    $objs[$data['idnumber']] = $obj->id;
                }
            }
        }

        if (!empty($roleassign)) {
            foreach ($roleassign as $assign) {
                $delim = strpos($assign['role_context'], ':');
                $ctxclass = substr($assign['role_context'], 0, $delim);
                $instid = $objs[substr($assign['role_context'], $delim + 1)];
                $context = $ctxclass::instance($instid);
                role_assign($DB->get_field('role', 'id', ['shortname' => $assign['role_shortname']]),
                        $DB->get_field('user', 'id', ['idnumber' => $assign['user_idnumber']]), $context->id);
            }
        }

        // Validation.
        $this->assert_data_produces_error($record, $expected['message'], 'enrolment');
        if (!empty($expected['user_idnumber']) && !empty($expected['role_shortname']) && !empty($expected['role_context'])) {
            $delim = strpos($expected['role_context'], ':');
            $ctxclass = substr($expected['role_context'], 0, $delim);
            $instid = $objs[substr($expected['role_context'], $delim + 1)];
            $context = $ctxclass::instance($instid);
            $userroles = get_user_roles($context, $DB->get_field('user', 'id', ['idnumber' => $expected['user_idnumber']]));
            $exists = false;
            foreach ($userroles as $userrole) {
                if ($userrole->shortname == $expected['role_shortname']) {
                    $exists = true;
                    break;
                }
            }
            $this->assertEquals($record['action'] == 'assign', $exists);
        }
    }
}
