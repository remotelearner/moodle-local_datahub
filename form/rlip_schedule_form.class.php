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

defined('MOODLE_INTERNAL') || die();

global $CFG;
require_once($CFG->dirroot.'/lib/formslib.php');
require_once($CFG->dirroot.'/local/datahub/lib.php');
require_once($CFG->dirroot.'/local/eliscore/lib/form/scheduling.php');
require_once($CFG->dirroot.'/local/eliscore/lib/form/timeselector.php');

/**
 * DataHub label scheduling step form base.
 */
class datahub_scheduling_form_step_label_base extends moodleform {
    /**
     * The form definition.
     */
    function definition() {
        require_js_files();
        $mform =& $this->_form;

        $page = $this->_customdata;
        $workflow = $page->workflow;

        $plugin = $page->required_param('plugin', PARAM_CLEAN);
        if (isset($workflow->id)) {
            $mform->addElement('hidden', '_wfid', $workflow->id);
            $mform->setType('_wfid', PARAM_INT);
        }
        $mform->addElement('hidden', 'id');
        $mform->setType('id', PARAM_INT);
        $mform->addElement('hidden', 'plugin', $plugin);
        $mform->setType('plugin', PARAM_CLEAN);
        list($type, $name) = explode('_', $plugin);
        $mform->addElement('hidden', 'name', $name);
        $mform->setType('name', PARAM_TEXT);
        $mform->addElement('hidden', 'type', $type);
        $mform->setType('type', PARAM_TEXT);

        $mform->addElement('html', get_string('rlip_form_'.$type.'_header', 'local_datahub'));

        $mform->addElement('hidden', '_step', datahub_scheduling_workflow::STEP_LABEL);
        $mform->setType('_step', PARAM_TEXT);
        $mform->addElement('hidden', 'action', 'save');
        $mform->setType('action', PARAM_TEXT);

        $mform->addElement('html', '<h2>'.htmlspecialchars(get_string('scheduling_labelstep', 'local_datahub')).'</h2>');

        $mform->addElement('text', 'label', get_string('rlip_form_label', 'local_datahub'));
        $mform->setType('label', PARAM_CLEAN);
        $mform->addRule('label', get_string('required_field', 'local_eliscore', get_string('rlip_form_label', 'local_datahub')), 'required', null, 'server');
        $mform->addHelpButton('label', 'rlip_form_label', 'local_datahub');

        // Add any custom fields for specific IP plugin form
        $this->add_custom_fields($mform);

        workflowpage::add_navigation_buttons($mform);
    }

    /**
     * Set error message for a form element
     *
     * @param     string    $element    Name of form element to set error for
     * @param     string    $message    Error message, if empty then removes the current error message
     * @since     1.0
     * @access    public
     * @return    void
     */
    function setElementError($element, $message = null) {
        $this->_form->setElementError($element, $message);
    }

    /**
     * Method to add custom fields to label step form.
     */
    function add_custom_fields($mform) {
        // Does nothing in base class.
    }
}

/**
 * DataHub label scheduling step form for import.
 */
class dhimport_scheduling_form_step_label extends datahub_scheduling_form_step_label_base {
    // Add file selections to base form
    function _add_custom_fields($mform) {
        $mform->addElement('html', '<hr/>');
        for ($i = 0; $i < count($this->_customdata['files']); $i++) {
            $mform->addElement('filepicker', 'file'.$i, $this->_customdata['files'][$i]);
        }
        $mform->addElement('html', '<hr/>');
    }
}

/**
 * DataHub label scheduling step form for export.
 */
class dhexport_scheduling_form_step_label extends datahub_scheduling_form_step_label_base {
}

