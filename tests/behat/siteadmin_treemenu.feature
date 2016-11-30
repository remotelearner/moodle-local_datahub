@local @local_datahub @javascript @dhimport_version1 @dhexport_version1 @dhimport_version1elis @dhexport_version1elis @dh_nophantom
Feature: Datahub custom menu items in Moodle Site Administration tree-menu.

    Background:
        Given I log in as "admin"
        And I am on homepage


    # T33.19 #1a
    Scenario: Test site administration menu custom node for Datahub settings.
        Then I navigate to "Datahub Settings" node in "Site administration > Plugins > Local plugins"

    Scenario: Test site administration menu custom node for Manage DataHub plugins.
        Then I navigate to "Manage plugins" node in "Site administration > Plugins > Local plugins > Data Hub plugins"

    Scenario: Test site administration menu custom node for Version1 Import Field Mappings.
        Then I navigate to "Field mapping" node in "Site administration > Plugins > Local plugins > Data Hub plugins > Version 1 import"

    Scenario: Test site administration menu custom node for Version1 Export Field Mappings.
        Then I navigate to "Field mapping" node in "Site administration > Plugins > Local plugins > Data Hub plugins > Version 1 export"

    Scenario: Test site administration menu custom node for DataHub logs.
        Then I navigate to "Data Hub logs" node in "Site administration > Reports"


    # T33.19 #1b
    Scenario: Test site administration menu custom node for Version1ELIS Import Field Mappings.
        Then I navigate to "Field mapping" node in "Site administration > Plugins > Local plugins > Data Hub plugins > Version 1 ELIS import"
    Scenario: Test site administration menu custom node for Version1ELIS Export Field Mappings.
        Then I navigate to "Field mapping" node in "Site administration > Plugins > Local plugins > Data Hub plugins > Version 1 ELIS export"

