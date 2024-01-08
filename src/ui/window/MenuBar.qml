import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtPositioning

import "../dialogs"

MenuBar  // MenuBar shown in the window's header
{
    id: menu_bar
    property int radius: 8

    property var name_filters: ["Organization Data Management Database file (*.odmdb)", "SQLite Database file (*.db)"]
    property var default_suffix: ".odmdb"

    Component
    {
        // component used for customizing the menu separator
        id: menu_separator_component

        Rectangle
        {
            implicitWidth: parent.width
            implicitHeight: 1
            color: backgroundColor1
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
                color: menuItem.highlighted ? backgroundColor1 : "transparent"
                radius: menu_bar.radius
                border.color: backgroundColor
                border.width: 2
            }
        }

        FileCloseDialog 
        {
            id: new_file_dialog
            function callback_function() { error_message = database.slot_readTemplateDB(); }
        }
        Action { text: qsTr("New"); onTriggered: new_file_dialog.show() }
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
                error_message = database.slot_readDB(selectedFile);
            }
        }
        Action { text: qsTr("Open"); onTriggered: open_file_dialog_1.show() }
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
                    color: menuItem.highlighted ? backgroundColor1 : "transparent"
                    radius: menu_bar.radius
                    border.color: backgroundColor
                    border.width: 2
                }
            }

            FileCloseDialog
            {
                id: open_recent_file_dialog
                property string db_path: ""
                function callback_function() { error_message = database.slot_readDB(db_path) }
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
                    let action = actionComponent.createObject(null, { text: "[No Recent Files]" });
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

            onAccepted: 
            {
                console.log("selected file:", selectedFile);
                error_message = database.slot_saveDB(selectedFile);
            }
        }
        Action { text: qsTr("Save"); onTriggered: {
            if(loaded_db_path === "") save_as_file_dialog.open();
            else error_message = database.slot_saveDB(loaded_db_path);
        } }
        Action { text: qsTr("Save As"); onTriggered: save_as_file_dialog.open() }

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
                color: menuItem.highlighted ? backgroundColor1 : "transparent"
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
                color: menuItem.highlighted ? backgroundColor1 : "transparent"
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
            color: menuBarItem.highlighted ? backgroundColor1 : "transparent"
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