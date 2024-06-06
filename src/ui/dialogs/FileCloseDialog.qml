import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"
import "../types"

ApplicationWindow
{
    id: dialog
    title: title_text
    color: backgroundColor1
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 200
    width: 300
    height: 200

    property string title_text: qsTr("Do you want to proceed?")
    property string main_text: qsTr("All unsaved changes will be lost.")
    property string sub_text: qsTr("Do you want to proceed?")
    property string ok_text: qsTr("Proceed")
    property string abort_text: qsTr("Abort")

    property bool remove_from_recent_file_list: false

    function init() {
        // Returns true if .show() should be called, otherwise false

        // Call this function before .show()
        ok_button.setFocus(Enums.FocusDir.Right);

        save_on_close_basic_checkbox.checked = settings.getAutoSaveOnClose();
        delete_from_recent_file_basic_checkbox.checked = false;
        remove_from_recent_file_list = false;

        // Don't show closing handler if a new and unchanged database is opened
        if(!unsaved_changes && db_path_text === new_db_text) {
            callback_function();
            return false;
        }

        return true;
    }

    Column
    {
        width: parent.width
        height: parent.height
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Text
        {
            text: main_text
            height: parent.height * 0.4 - parent.spacing
            width: parent.width
            font.pointSize: fontSize_default
            font.family: fontFamily_default
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.bold: true
            lineHeight: height * 0.4
            lineHeightMode: Text.FixedHeight
            maximumLineCount: 2
            wrapMode: Text.Wrap
        }

        BasicCheckbox
        {
            id: save_on_close_basic_checkbox
            height: parent.height * 0.2 - parent.spacing
            width: parent.width
            text: qsTr("Save automatically")
            onNextFocus: function next_focus(dir) {
                if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Save) ok_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Right) delete_from_recent_file_basic_checkbox.setFocus(dir);
                else if(dir === Enums.FocusDir.Up) ok_button.setFocus(dir);
                else abort_button.setFocus(dir);
            }
            enabled: db_path_text !== new_db_text

            onCheckedChanged: {
                settings.slot_setAutoSaveOnClose(checked);
            }
        }

        BasicCheckbox
        {
            id: delete_from_recent_file_basic_checkbox
            height: parent.height * 0.2 - parent.spacing
            width: parent.width
            text: qsTr("Remove file from recent files list")
            onNextFocus: function next_focus(dir) {
                if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Save) ok_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) save_on_close_basic_checkbox.setFocus(dir);
                else ok_button.setFocus(dir);
            }
            enabled: db_path_text !== new_db_text

            onCheckedChanged: {
                remove_from_recent_file_list = delete_from_recent_file_basic_checkbox.checked;
            }
        }

        Text
        {
            text: sub_text
            height: parent.height * 0.2 - parent.spacing
            width: parent.width
            font.pointSize: fontSize_default
            font.family: fontFamily_default
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.italic: true
        }
    }

    footer:
        Row
        {
            height: 27
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            property int column_count: 2

            BasicButton
            {
                id: ok_button
                text: ok_text
                height: parent.height - anchors.bottomMargin
                width: (parent.width - (parent.spacing * (parent.column_count - 1))) / parent.column_count
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                highlight_color: backgroundColorError
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) delete_from_recent_file_basic_checkbox.setFocus(dir);
                    else if(dir === Enums.FocusDir.Down) save_on_close_basic_checkbox.setFocus(dir);
                    else abort_button.setFocus(dir);
                }
                
                Component.onCompleted: setFocus(Enums.FocusDir.Right)

                onClicked:
                {
                    handle_autosave_on_close();
                }
            }

            BasicButton
            {
                id: abort_button
                text: abort_text
                height: parent.height - anchors.bottomMargin
                width: (parent.width - (parent.spacing * (parent.column_count - 1))) / parent.column_count
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                hover_color: textColor
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) clicked();
                    else if(dir === Enums.FocusDir.Save) ok_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Up) delete_from_recent_file_basic_checkbox.setFocus(dir);
                    else if(dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Right) save_on_close_basic_checkbox.setFocus(dir);
                    else ok_button.setFocus(dir);
                }

                onClicked:
                {
                    close();
                    ok_button.setFocus(Enums.FocusDir.Right);
                }
            }
        }

    function handle_recent_file() {
        if(remove_from_recent_file_list && delete_from_recent_file_basic_checkbox.enabled) {
            settings.slot_removeRecentFile(loaded_db_path);
        }

        callback_function();
    }

    Timer
    {
        id: save_timer
        interval: 10
        repeat: false

        onTriggered: {
            const msg = setStatusMessage(database.slot_saveDB(loaded_db_path), Enums.StatusMsgLvl.Err);
            busy_saving_indicator_dialog.close();
            if(msg !== "") {
                init();
                show();
                return;
            }

            handle_recent_file();
        }
    }

    function handle_autosave_on_close() {
        close();

        if((!settings.getAutoSaveOnClose()) || (loaded_db_path === "")) {
            handle_recent_file();
        } else {
            if(database.getUnsavedChanges()) {
                busy_saving_indicator_dialog.show();
                save_timer.start();
            } else {
                handle_recent_file();
            }
        }
    }
    
    function callback_function() {}
}