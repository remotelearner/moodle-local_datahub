@local @local_datahub @javascript @dhimport_version1 @dhexport_version1 @dhimport_version1elis @dhexport_version1elis
Feature: Datahub custom menu items in Moodle Site Administration tree-menu.

    Background:
        Given I log in as "admin"


    # T33.19 #1a
    Scenario: Test all site administration menu custom nodes.
        Then I navigate to "Datahub Settings" node in "Site administration > Plugins > Local plugins"
        Then I navigate to "Manage plugins" node in "Site administration > Plugins > Local plugins > Data Hub plugins"
        Then I navigate to "Field mapping" node in "Site administration > Plugins > Local plugins > Data Hub plugins > Version 1 import"
        Then I navigate to "Field mapping" node in "Site administration > Plugins > Local plugins > Data Hub plugins > Version 1 export"
        Then I navigate to "Data Hub logs" node in "Site administration > Reports"

    # T33.19 #1b
    Scenario: Test all site administration menu custom nodes with local_elisprogram installed.
        Then I navigate to "Field mapping" node in "Site administration > Plugins > Local plugins > Data Hub plugins > Version 1 ELIS import"
        Then I navigate to "Field mapping" node in "Site administration > Plugins > Local plugins > Data Hub plugins > Version 1 ELIS export"

