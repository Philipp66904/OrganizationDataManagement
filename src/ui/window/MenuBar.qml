import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtPositioning

import "../dialogs"
import "../types"

MenuBar  // MenuBar shown in the window's header
{
    id: menu_bar
    property int radius: 8

    property var name_filters: ["Organization Data Management Database file (*.odmdb)", "SQLite Database file (*.db)"]
    property var default_suffix: ".odmdb"

    function triggerNew() {
        action_new.trigger();
    }
    function triggerOpen() {
        action_open.trigger();
    }
    function triggerSave() {
        action_save.trigger();
    }
    function triggerSaveAs() {
        action_save_as.trigger();
    }

    Component
    {
        // component used for customizing the menu separator
        id: menu_separator_component

        Rectangle
        {
            implicitWidth: parent.width
            implicitHeight: 1
            color: backgroundColor2
        }
    }

    Component
    {
        // component used for customizing the menu background
        id: menu_background_component

        Rectangle
        {
            color: backgroundColor
            border.color: backgroundColor1
            border.width: 1
            radius: menu_bar.radius
            implicitWidth: 200
            implicitHeight: 40
        }
    }

    Component
    {
        // component used for customizing the action's text
        id: action_text_customization_component
        
        Text 
        {
            leftPadding: menuItem.indicator.width
            rightPadding: menuItem.arrow.width
            text: menuItem.text
            font.pointSize: (fontSize_small) ? fontSize_small : 1
            font.family: fontFamily_small
            color: menuItem.highlighted ? highlightColor : textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    Menu 
    {
        id: menu_title
        title: qsTr("File")
        background: Loader { sourceComponent: menu_background_component }
        delegate: MenuItem
        {
            id: menuItem
            implicitWidth: 200
            implicitHeight: 40

            contentItem: Row
            {
                rightPadding: menuItem.arrow.width
                spacing: 10
                property int column_count: 2

                Image
                {
                    id: icon_image
                    width: (parent.width - (parent.spacing * (parent.column_count - 1))) * 0.1
                    height: parent.height - 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    source: menuItem.icon.source
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                    verticalAlignment: Image.AlignVCenter
                }
                
                Text
                {
                    text: menuItem.text
                    width: parent.width - (parent.spacing * (parent.column_count - 1)) - icon_image.width
                    height: parent.height - 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    font.pointSize: (fontSize_small) ? fontSize_small : 1
                    font.family: fontFamily_small
                    color: menuItem.highlighted ? highlightColor : textColor
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    rightPadding: menuItem.arrow.width
                }
            }

            background: Rectangle
            {
                implicitWidth: 200
                implicitHeight: 40
                color: menuItem.highlighted ? backgroundColor2 : "transparent"
                radius: menu_bar.radius
                border.color: backgroundColor
                border.width: 2
            }
        }

        FileCloseDialog 
        {
            id: new_file_dialog
            function callback_function() {
                const msg = setStatusMessage(database.slot_readTemplateDB(), Enums.StatusMsgLvl.Err);
                if(msg !== "") return;

                setStatusMessage(qsTr("Created new file"), Enums.StatusMsgLvl.Info);
            }
        }
        Action
        {
            id: action_new
            text: qsTr("New")
            onTriggered: {
                if(new_file_dialog.init())
                    new_file_dialog.show();
            }
            icon.source: "../res/svg/paper_icon.svg"
        }
        MenuSeparator
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }

        FileCloseDialog 
        {
            id: open_file_dialog_1
            function callback_function() { open_file_dialog_2.open() }
        }
        FileDialog 
        {
            id: open_file_dialog_2
            fileMode: FileDialog.OpenFile
            nameFilters: name_filters

            onAccepted: {
                busy_loading_indicator_dialog.show();
                open_file_timer.start();
            }

            Timer
            {
                id: open_file_timer
                interval: 10
                repeat: false

                onTriggered: {
                    const msg = setStatusMessage(database.slot_readDB(open_file_dialog_2.selectedFile), Enums.StatusMsgLvl.Err);
                    busy_loading_indicator_dialog.close();
                    if(msg !== "") return;

                    setStatusMessage(qsTr("Opened file"), Enums.StatusMsgLvl.Info);
                }
            }
        }
        Action
        {
            id: action_open
            text: qsTr("Open")
            onTriggered: {
                if(open_file_dialog_1.init())
                    open_file_dialog_1.show();
            }
            icon.source: "../res/svg/folder_icon.svg"
        }
        Menu
        {
            id: open_recent_menu
            title: qsTr("Open Recent...")
            icon.source: "../res/svg/folder_recent_icon.svg"
            background: Loader { sourceComponent: menu_background_component }
            delegate: MenuItem {
                id: menuItem
                implicitWidth: 200
                implicitHeight: 40

                contentItem: Text
                {
                    leftPadding: menuItem.indicator.width
                    rightPadding: menuItem.arrow.width
                    text: menuItem.text
                    font.pointSize: (fontSize_small) ? fontSize_small : 1
                    font.family: fontFamily_small
                    color: menuItem.highlighted ? highlightColor : textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideLeft
                }

                background: Rectangle
                {
                    implicitWidth: 200
                    implicitHeight: 40
                    color: menuItem.highlighted ? backgroundColor2 : "transparent"
                    radius: menu_bar.radius
                    border.color: backgroundColor
                    border.width: 2
                }
            }

            FileCloseDialog
            {
                id: open_recent_file_dialog
                property string db_path: ""
                function callback_function() {
                    busy_loading_indicator_dialog.show();
                    open_recent_file_timer.start();
                }

                Timer
                {
                    id: open_recent_file_timer
                    interval: 10
                    repeat: false

                    onTriggered: {
                        const msg = setStatusMessage(database.slot_readDB(open_recent_file_dialog.db_path), Enums.StatusMsgLvl.Err);
                        busy_loading_indicator_dialog.close();
                        if(msg !== "") return;

                        setStatusMessage(qsTr("Recent file opened"), Enums.StatusMsgLvl.Info);
                    }
                }
            }

            Component 
            {
                id: actionComponent

                Action
                {
                    id: recent_file_action
                    property string db_path: ""
                    text: db_path
                    onTriggered: {
                        if(db_path === "") return;

                        open_recent_file_dialog.db_path = db_path;
                        if(open_recent_file_dialog.init())
                            open_recent_file_dialog.show();
                    }
                }
            }

            onAboutToShow: {
                // Delete all old paths
                while(open_recent_menu.actionAt(0) !== null) {
                    open_recent_menu.removeAction(open_recent_menu.actionAt(0));
                }

                // Add new paths
                for(let path of settings.getRecentFiles()) {
                    let action = actionComponent.createObject(open_recent_menu.contentItem, { db_path: path });
                    open_recent_menu.addAction(action);
                }

                // Add default action in case no recent files exist
                if(settings.getRecentFiles().length === 0) {
                    let action = actionComponent.createObject(open_recent_menu.contentItem, { enabled: false, text: "[" + qsTr("No Recent Files") + "]" });
                    open_recent_menu.addAction(action);
                }
            }
        }

        MenuSeparator 
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }

        FileDialog 
        {
            id: save_as_file_dialog
            fileMode: FileDialog.SaveFile
            nameFilters: name_filters
            defaultSuffix: default_suffix

            onAccepted: {
                busy_saving_indicator_dialog.show();
                save_as_timer.start();
            }

            Timer
            {
                id: save_as_timer
                interval: 10
                repeat: false

                onTriggered: {
                    const msg = setStatusMessage(database.slot_saveDB(save_as_file_dialog.selectedFile), Enums.StatusMsgLvl.Err);
                    busy_saving_indicator_dialog.close();
                    if(msg !== "") return;

                    setStatusMessage(qsTr("Saved as new file"), Enums.StatusMsgLvl.Info);
                }
            }
        }
        Action
        {
            id: action_save
            text: qsTr("Save")
            onTriggered: {
                if(loaded_db_path === "") {
                    save_as_file_dialog.open();
                } else {
                    if(database.getUnsavedChanges()) {
                        busy_saving_indicator_dialog.show();
                        save_timer.start();
                    } else {
                        setStatusMessage(qsTr("No changes to save"), Enums.StatusMsgLvl.Info);
                    }
                }
            }
            icon.source: "../res/svg/save_icon.svg"
        }
        Timer
        {
            id: save_timer
            interval: 10
            repeat: false

            onTriggered: {
                const msg = setStatusMessage(database.slot_saveDB(loaded_db_path), Enums.StatusMsgLvl.Err);
                busy_saving_indicator_dialog.close();
                if(msg !== "") return;

                setStatusMessage(qsTr("Saved file"), Enums.StatusMsgLvl.Info);
            }
        }
        Action
        {
            id: action_save_as
            text: qsTr("Save As")
            onTriggered: save_as_file_dialog.open()
            icon.source: "../res/svg/save_as_icon.svg"
        }

        MenuSeparator 
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }

        FileCloseDialog 
        {
            id: exit_dialog
            function callback_function() { Qt.exit(0) }
        }
        Action
        {
            id: action_exit
            text: qsTr("Exit")
            onTriggered: {
                if(exit_dialog.init())
                    exit_dialog.show();
            }
            icon.source: "../res/svg/exit_symbol.svg"
        }

    }

    Menu 
    {
        id: menu_settings
        title: qsTr("Settings")
        background: Loader { sourceComponent: menu_background_component }
        delegate: MenuItem {
            id: menuItem
            implicitWidth: 200
            implicitHeight: 40

            contentItem: Row
            {
                rightPadding: menuItem.arrow.width
                spacing: 10
                property int column_count: 2

                Image
                {
                    id: icon_image
                    width: (parent.width - (parent.spacing * (parent.column_count - 1))) * 0.1
                    height: parent.height - 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    source: menuItem.icon.source
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                    verticalAlignment: Image.AlignVCenter
                }
                
                Text
                {
                    text: menuItem.text
                    width: parent.width - (parent.spacing * (parent.column_count - 1)) - icon_image.width
                    height: parent.height - 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    font.pointSize: (fontSize_small) ? fontSize_small : 1
                    font.family: fontFamily_small
                    color: menuItem.highlighted ? highlightColor : textColor
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    rightPadding: menuItem.arrow.width
                }
            }

            background: Rectangle
            {
                implicitWidth: 200
                implicitHeight: 40
                color: menuItem.highlighted ? backgroundColor2 : "transparent"
                radius: menu_bar.radius
                border.color: backgroundColor
                border.width: 2
            }
        }

        LanguageSelectionDialog
        {
            id: language_selection_dialog
        }
        Action
        {
            id: action_change_language
            text: qsTr("Change Language")
            onTriggered: {
                language_selection_dialog.init();
                language_selection_dialog.show();
            }
        }

        ThemeEditDialog
        {
            id: theme_edit_dialog
        }
        Action
        {
            id: action_edit_color_theme
            text: qsTr("Edit Color Theme")
            onTriggered: {
                theme_edit_dialog.initListModel();
                theme_edit_dialog.show();
            }
        }

        FontEditDialog
        {
            id: font_edit_dialog
        }
        Action
        {
            id: action_edit_fonts
            text: qsTr("Edit Font Sizes")
            onTriggered: {
                font_edit_dialog.initListModel();
                font_edit_dialog.show();
            }
        }

        MenuSeparator 
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }

        Menu
        {
            id: open_advanced_settings
            title: qsTr("Advanced Settings") + "..."
            background: Loader { sourceComponent: menu_background_component }
            icon.source: "../res/svg/arrow_top_right.svg"
            delegate: MenuItem
            {
                id: menuItem
                implicitWidth: 200
                implicitHeight: 40

                contentItem: Text
                {
                    leftPadding: menuItem.indicator.width
                    rightPadding: menuItem.arrow.width
                    text: menuItem.text
                    font.pointSize: (fontSize_small) ? fontSize_small : 1
                    font.family: fontFamily_small
                    color: menuItem.highlighted ? highlightColor : textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle
                {
                    implicitWidth: 200
                    implicitHeight: 40
                    color: menuItem.highlighted ? backgroundColor2 : "transparent"
                    radius: menu_bar.radius
                    border.color: backgroundColor
                    border.width: 2
                }
            }

            Menu
            {
                id: open_file_association_settings
                title: qsTr("File association") + "..."
                background: Loader { sourceComponent: menu_background_component }
                delegate: MenuItem
                {
                    id: menuItem
                    implicitWidth: 200
                    implicitHeight: 40

                    contentItem: Text
                    {
                        leftPadding: menuItem.indicator.width
                        rightPadding: menuItem.arrow.width
                        text: menuItem.text
                        font.pointSize: (fontSize_small) ? fontSize_small : 1
                        font.family: fontFamily_small
                        color: menuItem.highlighted ? highlightColor : textColor
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle
                    {
                        implicitWidth: 200
                        implicitHeight: 40
                        color: menuItem.highlighted ? backgroundColor2 : "transparent"
                        radius: menu_bar.radius
                        border.color: backgroundColor
                        border.width: 2
                    }
                }

                Action
                {
                    id: action_status_registry_entries
                    text: qsTr("Status")
                    enabled: false
                }
                onAboutToShow: {
                    let text = qsTr("Status") + ": ";

                    if(winregistry.getRegistrySupported()) {
                        action_add_registry_entries.enabled = true;
                        action_remove_registry_entries.enabled = true;

                        if(settings.getFileTypeAssociation()) {
                            text += qsTr("Active");
                        } else {
                            text += qsTr("Inactive");
                        }
                    }
                    else {
                        action_add_registry_entries.enabled = false;
                        action_remove_registry_entries.enabled = false;
                        text += qsTr("Unsupported");
                    }

                    action_status_registry_entries.text = text;
                }

                MenuSeparator 
                {
                    contentItem: Loader { sourceComponent: menu_separator_component }
                }

                Action
                {
                    id: action_add_registry_entries
                    text: qsTr("Add file association")
                    onTriggered: {
                        settings.slot_setFileTypeAssociation(true);
                        winregistry.add_registry_entries(false);
                        setStatusMessage(qsTr("File association activated"), Enums.StatusMsgLvl.Info);
                    }
                }

                Action
                {
                    id: action_remove_registry_entries
                    text: qsTr("Remove file association")
                    onTriggered: {
                        settings.slot_setFileTypeAssociation(false);
                        winregistry.remove_registry_entries(false);
                        setStatusMessage(qsTr("File association deactivated"), Enums.StatusMsgLvl.Info);
                    }
                }
            }

            MenuSeparator 
            {
                contentItem: Loader { sourceComponent: menu_separator_component }
            }

            Menu
            {
                id: open_startmenu_settings
                title: qsTr("Startmenu") + "..."
                background: Loader { sourceComponent: menu_background_component }
                delegate: MenuItem
                {
                    id: menuItem
                    implicitWidth: 200
                    implicitHeight: 40

                    contentItem: Text
                    {
                        leftPadding: menuItem.indicator.width
                        rightPadding: menuItem.arrow.width
                        text: menuItem.text
                        font.pointSize: (fontSize_small) ? fontSize_small : 1
                        font.family: fontFamily_small
                        color: menuItem.highlighted ? highlightColor : textColor
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle
                    {
                        implicitWidth: 200
                        implicitHeight: 40
                        color: menuItem.highlighted ? backgroundColor2 : "transparent"
                        radius: menu_bar.radius
                        border.color: backgroundColor
                        border.width: 2
                    }
                }

                Action
                {
                    id: action_status_startmenu
                    text: qsTr("Status")
                    enabled: false
                }
                onAboutToShow: {
                    let text = qsTr("Status") + ": ";

                    if(startmenu.getStartmenuSupported()) {
                        action_add_to_startmenu.enabled = true;
                        action_remove_from_startmenu.enabled = true;

                        if(settings.getStartmenuState()) {
                            text += qsTr("Added");
                        } else {
                            text += qsTr("Removed");
                        }
                    }
                    else {
                        action_add_to_startmenu.enabled = false;
                        action_remove_from_startmenu.enabled = false;
                        text += qsTr("Unsupported");
                    }

                    action_status_startmenu.text = text;
                }

                MenuSeparator 
                {
                    contentItem: Loader { sourceComponent: menu_separator_component }
                }

                Action
                {
                    id: action_add_to_startmenu
                    text: qsTr("Add to startmenu")
                    onTriggered: {
                        settings.slot_setStartmenuState(true);
                        startmenu.add_to_startmenu(false);
                        setStatusMessage(qsTr("Added to startmenu"), Enums.StatusMsgLvl.Info);
                    }
                }

                Action
                {
                    id: action_remove_from_startmenu
                    text: qsTr("Remove from startmenu")
                    onTriggered: {
                        settings.slot_setStartmenuState(false);
                        startmenu.remove_from_startmenu(false);
                        setStatusMessage(qsTr("Removed from startmenu"), Enums.StatusMsgLvl.Info);
                    }
                }
            }
        }

        MenuSeparator 
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }

        TemplateDialog
        {
            id: recent_files_clear_dialog

            title_text: qsTr("Do you want to proceed?")
            main_text: qsTr("The recent files list will be cleared.")
            sub_text: qsTr("Do you want to proceed?")
            ok_text: qsTr("Clear Recent Files")
            abort_text: qsTr("Abort")

            function callback_function() {
                const msg = setStatusMessage(settings.slot_clearRecentFiles(), Enums.StatusMsgLvl.Err);
                if(msg !== "") return;

                setStatusMessage(qsTr("Recent files list cleared"), Enums.StatusMsgLvl.Info);
            }
        }
        Action
        {
            id: action_recent_files_clear
            text: qsTr("Clear Recent Files List", "Action Button")
            onTriggered: {
                recent_files_clear_dialog.init();
                recent_files_clear_dialog.show();
            }
        }

        TemplateDialog
        {
            id: settings_reset_dialog

            title_text: qsTr("Do you want to proceed?")
            main_text: qsTr("The settings will be set to the default values.")
            sub_text: qsTr("Do you want to proceed?")
            ok_text: qsTr("Reset Settings")
            abort_text: qsTr("Abort")

            function callback_function() {
                const msg = setStatusMessage(settings.resetSettings(), Enums.StatusMsgLvl.Err);
                if(msg !== "") return;

                init_colors();
                setStatusMessage(qsTr("Settings reset: Restart for all settings to take effect"), Enums.StatusMsgLvl.Info);
            }
        }
        Action
        {
            id: action_settings_reset
            text: qsTr("Reset Settings", "Action Button")
            onTriggered: {
                settings_reset_dialog.init();
                settings_reset_dialog.show();
            }
        }

        MenuSeparator 
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }

        TemplateDialog
        {
            id: program_uninstall_next_steps_dialog
            minimumWidth: 400
            width: 400

            title_text: qsTr("Program Uninstall Prepared Successfully")
            main_text: qsTr("You can now manually delete the directory\ncontaining the program data.")
            sub_text: qsTr("The program will close itself.")
            ok_text: qsTr("Understood")
            abort_text: qsTr("Abort")
            show_abort_button: false

            function callback_function() {
                rootWindow.close();
            }
        }
        TemplateDialog
        {
            id: program_prepare_uninstall_dialog
            minimumWidth: 400
            width: 400

            title_text: qsTr("Prepare Program Uninstall?")
            main_text: qsTr("The program removes all changes made to the OS.")
            sub_text: qsTr("Do you want to proceed?")
            ok_text: qsTr("Continue uninstall")
            abort_text: qsTr("Abort")

            function callback_function() {
                winregistry.remove_registry_entries(true);
                settings.slot_setFileTypeAssociation(false);
                startmenu.remove_from_startmenu(true);
                settings.slot_setStartmenuState(false);

                setStatusMessage(qsTr("Program uninstall prepared successfully"), Enums.StatusMsgLvl.Info);
                program_uninstall_next_steps_dialog.init();
                program_uninstall_next_steps_dialog.show();
            }
        }
        Action
        {
            id: action_prepare_program_uninstall
            text: qsTr("Prepare Program Uninstall")
            onTriggered: {
                program_prepare_uninstall_dialog.init();
                program_prepare_uninstall_dialog.show();
            }
        }
    }

    Menu 
    {
        id: menu_help
        title: qsTr("Help")
        background: Loader { sourceComponent: menu_background_component }
        delegate: MenuItem {
            id: menuItem
            implicitWidth: 200
            implicitHeight: 40

            contentItem: Row
            {
                rightPadding: menuItem.arrow.width
                spacing: 10
                property int column_count: 2

                Image
                {
                    id: icon_image
                    width: (parent.width - (parent.spacing * (parent.column_count - 1))) * 0.1
                    height: parent.height - 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    source: menuItem.icon.source
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignLeft
                    verticalAlignment: Image.AlignVCenter
                }
                
                Text
                {
                    text: menuItem.text
                    width: parent.width - (parent.spacing * (parent.column_count - 1)) - icon_image.width
                    height: parent.height - 8
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    font.pointSize: (fontSize_small) ? fontSize_small : 1
                    font.family: fontFamily_small
                    color: menuItem.highlighted ? highlightColor : textColor
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    rightPadding: menuItem.arrow.width
                }
            }

            background: Rectangle
            {
                implicitWidth: 200
                implicitHeight: 40
                color: menuItem.highlighted ? backgroundColor2 : "transparent"
                radius: menu_bar.radius
                border.color: backgroundColor
                border.width: 2
            }
        }

        Action
        {
            id: action_user_guide
            text: qsTr("User Guide")
            onTriggered: {
                Qt.openUrlExternally("https://github.com/Philipp66904/OrganizationDataManagement/wiki/User-Guide");
            }
            icon.source: "../res/svg/globe_icon.svg"
        }

        MenuSeparator
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }

        Action
        {
            id: action_documentation
            text: qsTr("Documentation")
            onTriggered: {
                Qt.openUrlExternally("https://github.com/Philipp66904/OrganizationDataManagement/wiki/Documentation");
            }
            icon.source: "../res/svg/globe_icon.svg"
        }

        Action
        {
            id: action_github
            text: qsTr("Github")
            onTriggered: {
                Qt.openUrlExternally("https://github.com/Philipp66904/OrganizationDataManagement");
            }
            icon.source: "../res/svg/globe_icon.svg"
        }

        MenuSeparator
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }

        AboutDialog { id: about_dialog; }
        Action
        {
            id: action_about
            text: qsTr("About")
            onTriggered: {
                about_dialog.init();
                about_dialog.show();
            }
        }

        LicensesDialog { id: licenses_dialog; }
        Action
        {
            id: action_licenses
            text: qsTr("Licenses")
            onTriggered: {
                licenses_dialog.init();
                licenses_dialog.show();
            }
        }
    }

    delegate: MenuBarItem
    {
        id: menuBarItem

        contentItem: Text
        {
            text: menuBarItem.text
            font.pointSize: (fontSize_default) ? fontSize_default : 1
            font.family: fontFamily_default
            color: menuBarItem.highlighted ? highlightColor : textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle
        {
            implicitWidth: 40
            implicitHeight: 30
            color: menuBarItem.highlighted ? backgroundColor2 : "transparent"
            border.color: backgroundColor
            border.width: 2
            radius: menu_bar.radius
        }
    }

    background: Rectangle
    {
        implicitWidth: 40
        implicitHeight: 30
        color: "transparent"

        Rectangle
        {
            color: backgroundColor3
            width: parent.width
            height: 1
            anchors.top: parent.bottom
            anchors.topMargin: 1
        }
    }
}