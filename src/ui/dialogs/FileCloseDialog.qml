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
    minimumHeight: 170
    width: 300
    height: 170

    property string title_text: qsTr("Do you want to proceed?")
    property string main_text: qsTr("All unsaved changes will be lost.")
    property string sub_text: qsTr("Do you want to proceed?")
    property string ok_text: qsTr("Proceed")
    property string abort_text: qsTr("Abort")

    property bool remove_from_recent_file_list: false

    function init() {
        // Call this function before .show()
        ok_button.setFocus(Enums.FocusDir.Right);

        delete_from_recent_file_basic_checkbox.checked = false;
        remove_from_recent_file_list = false;
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
            height: parent.height * 0.5 - parent.spacing
            width: parent.width
            font.pointSize: textSize
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
            id: delete_from_recent_file_basic_checkbox
            height: parent.height * 0.25 - parent.spacing
            width: parent.width
            text: qsTr("Remove file from recent files list")
            onNextFocus: function next_focus(dir) {
                if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Save) ok_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Right) ok_button.setFocus(dir);
                else abort_button.setFocus(dir);
            }
            enabled: db_path_text !== new_db_text

            onCheckedChanged: {
                remove_from_recent_file_list = delete_from_recent_file_basic_checkbox.checked;
            }
        }

        Text
        {
            text: sub_text
            height: parent.height * 0.25 - parent.spacing
            width: parent.width
            font.pointSize: textSize
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

            BasicButton
            {
                id: ok_button
                text: ok_text
                height: parent.height - anchors.bottomMargin
                width: (parent.width - parent.spacing) / 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                highlight_color: backgroundColorError
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Left) delete_from_recent_file_basic_checkbox.setFocus(dir);
                    else abort_button.setFocus(dir);
                }
                
                Component.onCompleted: setFocus(Enums.FocusDir.Right)

                onClicked:
                {
                    handle_recent_file();
                    close();
                }

            }

            BasicButton
            {
                id: abort_button
                text: abort_text
                height: parent.height - anchors.bottomMargin
                width: (parent.width - parent.spacing) / 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                hover_color: textColor
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) clicked();
                    else if(dir === Enums.FocusDir.Save) ok_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Right) delete_from_recent_file_basic_checkbox.setFocus(dir);
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
    
    function callback_function() {}
}