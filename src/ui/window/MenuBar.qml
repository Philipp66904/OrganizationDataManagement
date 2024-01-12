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
            font.pointSize: textSizeSmall
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
        delegate: MenuItem {
            id: menuItem
            implicitWidth: 200
            implicitHeight: 40

            contentItem: Text {
                leftPadding: menuItem.indicator.width
                rightPadding: menuItem.arrow.width
                text: menuItem.text
                font.pointSize: textSizeSmall
                color: menuItem.highlighted ? highlightColor : textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
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
            onTriggered: new_file_dialog.show()
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

            onAccepted: 
            {
                const msg = setStatusMessage(database.slot_readDB(selectedFile), Enums.StatusMsgLvl.Err);
                if(msg !== "") return;

                setStatusMessage(qsTr("Opened file"), Enums.StatusMsgLvl.Info);
            }
        }
        Action
        {
            id: action_open
            text: qsTr("Open")
            onTriggered: open_file_dialog_1.show()
        }
        Menu
        {
            id: open_recent_menu
            title: qsTr("Open Recent...")
            background: Loader { sourceComponent: menu_background_component }
            delegate: MenuItem {
                id: menuItem
                implicitWidth: 200
                implicitHeight: 40

                contentItem: Text {
                    leftPadding: menuItem.indicator.width
                    rightPadding: menuItem.arrow.width
                    text: menuItem.text
                    font.pointSize: textSizeSmall
                    color: menuItem.highlighted ? highlightColor : textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideLeft
                }

                background: Rectangle {
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
                    const msg = setStatusMessage(database.slot_readDB(db_path), Enums.StatusMsgLvl.Err);
                    if(msg !== "") return;

                    setStatusMessage(qsTr("Recent file opened"), Enums.StatusMsgLvl.Info);
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
                    let action = actionComponent.createObject(open_recent_menu.contentItem, { text: "[No Recent Files]" });
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
                const msg = setStatusMessage(database.slot_saveDB(selectedFile), Enums.StatusMsgLvl.Err);
                if(msg !== "") return;

                setStatusMessage(qsTr("Saved as new file"), Enums.StatusMsgLvl.Info);
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
                    const msg = setStatusMessage(database.slot_saveDB(loaded_db_path), Enums.StatusMsgLvl.Err);
                    if(msg !== "") return;

                    setStatusMessage(qsTr("Saved file"), Enums.StatusMsgLvl.Info);
                }
            }
        }
        Action
        {
            id: action_save_as
            text: qsTr("Save As")
            onTriggered: save_as_file_dialog.open()
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
        Action { text: qsTr("Exit"); onTriggered: exit_dialog.show() }

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

            contentItem: Text {
                leftPadding: menuItem.indicator.width
                rightPadding: menuItem.arrow.width
                text: menuItem.text
                font.pointSize: textSizeSmall
                color: menuItem.highlighted ? highlightColor : textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 40
                color: menuItem.highlighted ? backgroundColor2 : "transparent"
                radius: menu_bar.radius
                border.color: backgroundColor
                border.width: 2
            }
        }

        ThemeEditDialog
        {
            id: theme_edit_dialog
        }
        Action { text: qsTr("Edit Color Theme"); onTriggered: {
                theme_edit_dialog.initListModel();
                theme_edit_dialog.show();
        } }
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

            contentItem: Text {
                leftPadding: menuItem.indicator.width
                rightPadding: menuItem.arrow.width
                text: menuItem.text
                font.pointSize: textSizeSmall
                color: menuItem.highlighted ? highlightColor : textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 200
                implicitHeight: 40
                color: menuItem.highlighted ? backgroundColor2 : "transparent"
                radius: menu_bar.radius
                border.color: backgroundColor
                border.width: 2
            }
        }

        Action { text: qsTr("About") }

        MenuSeparator 
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }
        Action { text: qsTr("Github") }
        Action { text: qsTr("Search for updates") }

        MenuSeparator 
        {
            contentItem: Loader { sourceComponent: menu_separator_component }
        }
        Action { text: qsTr("Licences") }
    }

    delegate: MenuBarItem {
        id: menuBarItem

        contentItem: Text {
            text: menuBarItem.text
            font.pointSize: textSize
            color: menuBarItem.highlighted ? highlightColor : textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 40
            implicitHeight: 30
            color: menuBarItem.highlighted ? backgroundColor2 : "transparent"
            border.color: backgroundColor
            border.width: 2
            radius: menu_bar.radius
        }
    }

    background: Rectangle {
        implicitWidth: 40
        implicitHeight: 30
        color: "transparent"

        Rectangle {
            color: backgroundColor3
            width: parent.width
            height: 1
            anchors.top: parent.bottom
            anchors.topMargin: 1
        }
    }
}