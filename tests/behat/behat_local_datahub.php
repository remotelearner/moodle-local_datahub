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
        // Remove the dynamic userid parameter.
        $this->received = preg_replace('#\"id\"\:([0-9]{6})\,#', '', $this->received);
        if ($this->received !== $string) {
            $msg = "Web Service call failed\n";
            $msg .= "Received ".$this->received."\n";
            $msg .= "Expected ".$string."\n";
            throw new \Exception($msg);
        }
    }

    /**
     * @Given A multi-valued custom field exists with name :arg1 for the :arg2 context with options :arg3
     */
    public function aMultiValuedCustomFieldExistsWithNameForTheContextWithOptions($arg1, $arg2, $arg3) {
        global $DB;

        $catrec = [
            'name' => 'test',
            'sortorder' => 0,
        ];
        $catrec['id'] = $DB->insert_record('local_eliscore_field_cats', (object)$catrec);

        $catctxrec = [
            'categoryid' => $catrec['id'],
            'contextlevel' => 15,
        ];
        $catctxrec['id'] = $DB->insert_record('local_eliscore_fld_cat_ctx', (object)$catctxrec);

        $fieldrec = [
            'shortname' => $arg1,
            'name' => $arg1,
            'datatype' => 'char',
            'description' => '',
            'categoryid' => $catrec['id'],
            'sortorder' => 0,
            'multivalued' => 1,
            'forceunique' => 0,
            'params' => 'a:0:{}',
        ];
        $fieldrec['id'] = $DB->insert_record('local_eliscore_field', (object)$fieldrec);

        $ownerrec = [
            'fieldid' => $fieldrec['id'],
            'plugin' => 'manual',
            'exclude' => 0,
            'params' => json_encode([
                'required' => 0,
                'edit_capability' => '',
                'view_capability' => '',
                'control' => 'menu',
                'options_source' => '',
                'options' => implode("\n", ['Option 1', 'Option 2', 'Option 3', 'Option 4']),
                'columns' => 30,
                'rows' => 10,
                'maxlength' => 2048,
                'startyear' => 1970,
                'stopyear' => 2038,
                'inctime' => '0',
            ]),
        ];
        $ownerrec['id'] = $DB->insert_record('local_eliscore_field_owner', (object)$ownerrec);

        $fieldclevelsrec = [
            'fieldid' => $fieldrec['id'],
            'contextlevel' => 15,
        ];
        $fieldclevelsrec['id'] = $DB->insert_record('local_eliscore_field_clevels', (object)$fieldclevelsrec);

    }
}
