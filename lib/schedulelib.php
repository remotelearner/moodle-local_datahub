<?php
/**
 * ELIS(TM): Enterprise Learning Intelligence Suite
 * Copyright (C) 2008-2015 Remote-Learner.net Inc (http://www.remote-learner.net)
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
 * @package    local_datahub
 * @author     Remote-Learner.net Inc
 * @license    http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 * @copyright  (C) 2008-2015 Remote-Learner.net Inc (http://www.remote-learner.net)
 *
 */

require_once(dirname(__FILE__).'/../../../config.php');
require_once($CFG->dirroot.'/local/eliscore/lib/setup.php');
require_once($CFG->dirroot.'/local/eliscore/lib/tasklib.php');
require_once($CFG->dirroot.'/local/eliscore/lib/workflow.class.php');
require_once($CFG->dirroot.'/local/eliscore/lib/workflowpage.class.php');
require_once($CFG->dirroot.'/local/eliscore/lib/schedulingtraits.php');
require_once($CFG->dirroot.'/local/datahub/lib.php');
require_once($CFG->dirroot.'/local/datahub/lib/rlip_dataplugin.class.php');
require_once($CFG->dirroot.'/local/datahub/form/rlip_schedule_form.class.php');

/**
 * DataHub scheduling workflow data.  Data is an array with the following keys:
 * plugin: the datahub schedule type.
 * label: the datahub schedule label
 * timezone: the time zone of the schedule
 * startdate: the date to start (null for now)
 * recurrencetype: (the recurrence type 'simple' or 'calendar' or 'period')
 * schedule: schedule data (array), depending on the recurrence type
 *   if simple, keys are:
 *     enddate: date to run until (or null)
 *     runsremaining: number of runs (or null)
 *     frequency: how often to run (if runsremaning is non-null)
 *     frequencytype: hour/day/month (if runsremaning is non-null)
 *   if calendar, keys are:
 *     enddate: date to run until (or null)
 *     hour:
 *     minute:
 *     dayofweek:
 *     day:
 *     month:
 */
class datahub_scheduling_workflow extends workflow {
    use elisschedulingworkflowtrait;
    const STEP_LABEL = 'label';
    const STEP_SCHEDULE = 'schedule';

    /**
     * Constructor: data_object
     * @param mixed $src record source. It can be
     * - false: an empty object is created
     * - an integer: loads the record that has record id equal to $src
     * - an object: creates an object with field data taken from the members
     *   of $src
     * - an array: creates an object with the field data taken from the
     *   elements of $src
     * @param mixed $fieldmap mapping for field names from $src.  If it is a
     * string, then it will be treated as a prefix for field names.  If it is
     * an array, then it is a mapping of destination field names to source
     * field names.
     * @param array $associations pre-fetched associated objects (to avoid
     * needing to re-fetch)
     * @param boolean $fromdb whether or not the record source object/array
     * comes from the database
     * @param array $extradatafields extra data from the $src object/array
     * associated with the record that should be kept in the data object (such
     * as counts of related records)
     * @param moodle_database $database database object to use (null for the
     * default database)
     */
    public function __construct($src = false, $fieldmap = null, array $associations = array(), $fromdb = false, array $extradatafields = array(),
            moodle_database $database = null) {
        parent:: __construct($src, $fieldmap, $associations, $fromdb, $extradatafields, $database);
        $this->init_schedule_trait($this);
    }

    /**
     * Get workflow steps.
     * @return array the workflow steps.
     */
    public function get_steps() {
        return array(
            self::STEP_LABEL    => get_string('scheduling_labelstep', 'local_datahub'),
            self::STEP_SCHEDULE => get_string('scheduling_schedulestep', 'local_datahub')
            //, self::STEP_CONFIRM  => ' '
        );
    }

    /**
     * Get last completed step.
     * @return string The last completed step (key).
     */
    public function get_last_completed_step() {
        $data = $this->unserialize_data(array());
        if (!isset($data['label'])) {
            return null;
        }
        if (!isset($data['recurrencetype']) && empty($data['period'])) {
            return self::STEP_LABEL;
        }
        return self::STEP_SCHEDULE;
    }

    /**
     * Save label and any custom fields/files.
     * @param object $values the form element values.
     */
    public function save_values_for_step_label($values) {
        if (empty($values->label)) {
            return array('label' => get_string('required'));
        }
        $data = $this->unserialize_data(array());
        if (!isset($this->id)) {
            // $data['type'] = $values->type;
            // $data['name'] = $values->name;
            $data['plugin'] = $values->plugin;
        }
        $data['label'] = $values->label;
        // TBD: files!
        $this->data = serialize($data);
        $this->save();
    }

    /**
     * The finish method
     * @return int|bool The task record DB id (> 0) on success, or false on error.
     */
    public function finish() {
        global $USER, $DB;

        $data = $this->unserialize_data(array());
        if (isset($data['submitbutton'])) { // formslib!
            unset($data['submitbutton']);
        }
        if (isset($data['userid'])) {
            // The userid was specifically persisted from the schedule record.
            $userid = $data['userid'];
        } else {
            // Default to the current user.
            $userid = $USER->id;
        }

        // Add timemodified to serialized data.
        $data['timemodified'] = time();

        // Save ipjob to schedule table - id (auto), userid (Moodle userid), plugin, config($data plus time() <= currenttime).
        $ipjob  = new stdClass;
        $ipjob->userid = $userid;
        $ipjob->plugin = $data['plugin'];
        $ipjob->config = serialize($data);

        if (!empty($data['schedule_id'])) {
            $ipjob->id = $data['schedule_id'];
            $DB->update_record(RLIP_SCHEDULE_TABLE, $ipjob);
        } else {
            $ipjob->id = $DB->insert_record(RLIP_SCHEDULE_TABLE, $ipjob);
        }

        // Save to scheduled_tasks.
        $taskname     = 'ipjob_'.$ipjob->id;
        $component    = 'local_datahub';
        $callfile     = '/local/datahub/lib.php';
        $callfunction = 'run_ipjob';
        $taskid = $this->save_elis_scheduled_task($taskname, $component, $callfile, $callfunction, $data);
        // Must save the nextruntime in the RLIP_SCHEDULE_TABLE too! So run_ipjob() can reset on error, etc.
        $ipjob->nextruntime = $DB->get_field('local_eliscore_sched_tasks', 'nextruntime', array('id' => $taskid));
        $DB->update_record(RLIP_SCHEDULE_TABLE, $ipjob);
        return $taskid;
    }
}

/**
 * The DataHub scheduleing page class.
 */
class ip_schedule_page extends workflowpage {
    use elisschedulingpagetrait;
    /** @var $data_class the workflow associated with page. */
    public $data_class = 'datahub_scheduling_workflow';

    /** @var string The scheduling form. */
    public $schedule_form = 'scheduling_form_step_schedule';

    /** @var bool Enable scheduling period historic datahub format. */
    public $schedule_period = true;

    /** @var string The DataHub schedule type: 'dhimport' or 'dhexport'. */
    protected $type;
    /** @var string The DataHub schedule name: 'version1', 'version1elis'. */
    protected $name;

    /**
     * Constructor: elis_page to initialize elisschedulingpagetrait.
     * @param array $params array of URL parameters.
     */
    public function __construct(array $params = null) {
        parent::__construct($params);
        $this->init_schedule_trait($this);
    }

    /**
     * Set page header requirements
     */
    protected function get_header_requirements() {
        $this->requires->jquery();
        $this->requires->jquery_plugin('ui');
        $this->requires->jquery_plugin('ui-css');
        $this->requires->css('/local/eliscore/styles.css');
        $this->requires->css('/local/datahub/styles.css');
    }

    /**
     * Gets base page params, i.e. plugin.
     */
    private function get_base_page_params() {
        $plugin = $this->optional_param('plugin', '', PARAM_CLEAN);
        if (empty($plugin)) {
            $plugin = required_param('plugin', PARAM_CLEAN);
        }
        list($this->type, $this->name) = explode('_', $plugin);
    }

    /**
     * Reconstruct plugin from parts.
     * @return string the datahub plugin.
     */
    private function get_ip_plugin() {
        return "{$this->type}_{$this->name}";
    }

    /**
     * Gets page URL.
     * @return string the page URL.
     */
    protected function _get_page_url() {
        global $CFG;
        return "{$CFG->wwwroot}/local/datahub/schedulepage.php";
    }

    /**
     * Method to add & output form buttons.
     */
    private function add_submit_cancel_buttons($submiturl, $submitlabel,
                                               $cancelurl = null, $cancellabel = '') {
        global $OUTPUT;
        echo $OUTPUT->single_button($submiturl, $submitlabel);
        if ($cancelurl) {
            if (empty($cancellabel)) {
                $cancellabel = get_string('cancel');
            }
            echo $OUTPUT->single_button($cancelurl, $cancellabel);
        }
    }

    /**
     * Get page title.
     * @return string the title.
     */
    function get_page_title_default() {
        global $DB;

        $scheduleid = optional_param('id', 0, PARAM_INT);
        // If a schedule id was in the url, then attempt to retrieve it from the php_scheduled_tasks table
        if ($scheduleid) {
            $schedule = $DB->get_record(RLIP_SCHEDULE_TABLE, array('id' => $scheduleid));
            if (!empty($schedule)) {
                $this->workflow->data = $schedule->config;
                $workflowdata = $this->workflow->unserialize_data(array());
                $workflowdata['schedule_id'] = $scheduleid;
                $this->workflow->data = serialize($workflowdata);
                $this->workflow->save();
            }
        }

        // TBD: could check param 'plugin' & show different import/export title
        return get_string('schedulepagetitle', 'local_datahub');
    }

    /**
     * Build Navigation bar.
     */
    function build_navbar_default() {
        global $CFG;

        //add navigation items
        $this->navbar->add(get_string('administrationsite'));
        $this->navbar->add(get_string('plugins', 'admin'));
        $this->navbar->add(get_string('localplugins'));
        $this->navbar->add(get_string('plugins', 'local_datahub'));
        $this->navbar->add(get_string('rlipmanageplugins', 'local_datahub'), new moodle_url('/local/datahub/plugins.php'));
        $this->navbar->add(get_string('schedulepagetitle', 'local_datahub'), null);
    }

    /**
     * Can do default method.
     * @return bool whether user can perform the operation.
     */
    function can_do_default() {
        if (has_capability('moodle/site:config', context_system::instance())) {
            return true;
        }
        return false;
    }

    /**
     * The main listing method.
     */
    public function display_list() {
        global $OUTPUT, $USER;
        $this->get_base_page_params();
        $display_name = $this->get_ip_plugin(); // TBD: more user-friendly
        $ipscheds = rlip_get_scheduled_jobs($this->get_ip_plugin(),
                                            is_siteadmin() ? 0 : $USER->id);
        if (!empty($ipscheds) && $ipscheds->valid()) {
            echo $OUTPUT->notification(get_string("rlip_jobs_heading_jobs",
                                                  'local_datahub', get_string('pluginname', $display_name)),
                                       'rlip_bold_header', 'left');
            echo $OUTPUT->notification(get_string('rlip_jobs_heading_fullinstructions',
                                                  'local_datahub', $display_name),
                                       'rlip_italic_header', 'left');
            $table = new html_table();
            $table->head = array(
                          get_string('rlip_jobs_header_label', 'local_datahub'),
                          get_string('rlip_jobs_header_owner', 'local_datahub'),
                          get_string('rlip_jobs_header_lastran', 'local_datahub'),
                          get_string('rlip_jobs_header_nextrun', 'local_datahub'),
                          get_string('rlip_jobs_header_modified', 'local_datahub'),
                          '' // Actions: Edit/Delete
                         );
            $table->align      = array('left', 'center', 'left', 'left', 'left', 'center');
            $table->size       = array('5%', '15%', '25%', '25%', '25%', '5%');
            $table->data       = array();
            $table->rowclasses = array(); //TBD
            $edit = get_string('edit');
            $delete = get_string('delete');
            foreach ($ipscheds as $ipjob) {
                $ustr = "{$ipjob->username}<br/>(".datahub_fullname($ipjob).')';
                $tz   = $ipjob->timezone;
                $data = unserialize($ipjob->config);
                $lastruntime = !empty($ipjob->lastruntime)
                               ? userdate($ipjob->lastruntime, '', $tz)
                                 .' (' . usertimezone($tz) .')'
                               : get_string('no_lastruntime', 'local_datahub');
                $nextruntime = !empty($ipjob->nextruntime)
                               ? userdate($ipjob->nextruntime, '', $tz)
                                 .' (' . usertimezone($tz) .')'
                               : get_string('na', 'local_datahub');
                $modified = !empty($data['timemodified'])
                            ? userdate($data['timemodified'], '', $tz)
                              .' (' . usertimezone($tz) .')'
                            : get_string('na', 'local_datahub');
                $target = $this->get_new_page(array('id' => $ipjob->id, 'plugin' => $ipjob->plugin, 'action' => 'list')); // TBD.
                $label = '<a name="edit" href="'. $target->url->out(true, array('action' => 'default')) .'">'. $data['label'] .'</a>';
                $edit_link = '<a name="edit" href="'. $target->url->out(true, array('action' => 'default')) .'"><img alt="'. $edit .'" title="'. $edit .'" src="'. $OUTPUT->pix_url('t/edit') .'" /></a>';
                $delete_link = '<a name="delete" href="'. $target->url->out(true, array('action' => 'delete')) .'"><img alt="'. $delete .'" title="'. $delete .'" src="'. $OUTPUT->pix_url('t/delete') .'" /></a>';
                $table->rowclasses[] = ''; //TBD
                $table->data[] = array($label, $ustr, $lastruntime,
                                       $nextruntime, $modified,
                                       "{$edit_link}&nbsp;{$delete_link}"
                                 );
            }
            echo html_writer::table($table);

            echo $OUTPUT->notification(get_string('schedulingtime',
                                                  'local_datahub', $display_name),
                                       'rlip_italic_header', 'left');
        } else {
            echo $OUTPUT->notification(get_string('rlip_jobs_heading_nojobs',
                                                  'local_datahub', get_string('pluginname', $display_name)),
                                       'rlip_bold_header', 'left');
            echo $OUTPUT->notification(get_string('rlip_jobs_heading_instructions',
                                                  'local_datahub', $display_name),
                                       'rlip_italic_header', 'left');
        }
        echo $OUTPUT->spacer();
        $submit = $this->get_new_page(array('action' => 'default', 'plugin' => $this->get_ip_plugin()));
        $this->add_submit_cancel_buttons($submit->url, get_string('rlip_new_job', 'local_datahub'));
    }

    /**
     * The display delete method.
     */
    function display_delete() {
        global $DB, $OUTPUT;
        $this->get_base_page_params();
        $id = $this->required_param('id', PARAM_INT);
        $confirm = $this->optional_param('confirm', 0, PARAM_INT);
        if ($confirm) {
            rlip_schedule_delete_job($id);
            $this->display_list(); // TBD.
        } else {
            $target = $this->get_new_page(array('id' => $id, 'plugin' => $this->get_ip_plugin(), 'action' => 'list')); // TBD.
            $continue_url = new moodle_url($target->url->out(true, array('action' => 'delete', 'confirm' => 1)));
            $buttoncontinue = new single_button($continue_url, get_string('yes'));
            $cancel_url = new moodle_url($target->url->out(true, array('action' => 'list')));
            $buttoncancel = new single_button($cancel_url, get_string('no'));
            echo $OUTPUT->confirm(get_string('confirm_delete_ipjob', 'local_datahub', $id), $buttoncontinue, $buttoncancel);
        }
    }

    /**
     * Method to display first schedule step.
     * @param array $errors Form element validation errors.
     */
    public function display_step_label($errors) {
        $workflowdata = $this->workflow->unserialize_data(array());
        if (isset($workflowdata['plugin'])) {
            $this->params['plugin'] = $workflowdata['plugin'];
        }
        $this->get_base_page_params();
        $formclass = $this->type.'_scheduling_form_step_label';
        $form = new $formclass(null, $this);
        if ($errors) {
            foreach ($errors as $element => $msg) {
                $form->setElementError($element, $msg);
            }
        }
        $data = new stdClass;
        if (isset($workflowdata['label'])) {
            $data->label = $workflowdata['label'];
        }
        // TBD: files.
        $form->set_data($data);
        $form->display();
    }

    /**
     * Method to get form data for label schedule step.
     * @return object The form data.
     */
    public function get_submitted_values_for_step_label() {
        $this->get_base_page_params();
        $formclass = $this->type.'_scheduling_form_step_label';
        $form = new $formclass(null, $this);
        $data = $form->get_data(false);
        return $data;
    }

    /**
     * Confirmation step.
     * @param array $errors Form element validation errors.
     */
    public function display_step_confirm($errors) {
        error_log("datahub/lib/schedulelib.php::display_step_confirm()");
        $target = $this->get_new_page(array('_wfid' => $this->workflow->id, 'action' => 'finish'));
        redirect($target->url);
    }

    /**
     * Required display_finished() method.
     */
    public function display_finished() {
        $workflowdata = $this->workflow->unserialize_data(array());
        if (isset($workflowdata['plugin'])) {
            $this->params['plugin'] = $workflowdata['plugin'];
        }
        $id = $this->optional_param('id', 0, PARAM_INT);
        $this->get_base_page_params();
        $target = $this->get_new_page(array('id' => $id, 'plugin' => $this->get_ip_plugin(), 'action' => 'list')); // TBD.
        redirect($target->url, get_string('saved', 'repository'));
    }

    /**
     * Gets the scheduling step titles.
     * @return string
     */
    public function get_schedule_step_title() {
        $workflowdata = $this->workflow->unserialize_data(array());
        if (isset($workflowdata['plugin'])) {
            $this->params['plugin'] = $workflowdata['plugin'];
        }
        $this->get_base_page_params();
        $displaytype = ucwords(substr($this->type, 2));
        return get_string('schedule_step_title', 'local_datahub', $displaytype);
    }

    /**
     * Static method to format variable for error output.
     * @param mixed $var the variable to dump.
     * @return string the formatted variable data.
     */
    public static function err_dump($var) {
        ob_start();
        var_dump($var);
        $tmp = ob_get_contents();
        ob_end_clean();
        return $tmp;
    }

    /**
     * List the schedule.
     */
    public function print_summary() {
        // TBD.
    }
}
