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
    title: qsTr("Do you want to proceed?")
    color: backgroundColor1
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 140
    width: 330
    height: 180
    property string text: qsTr("The specified entry will be deleted.")
    property string subtext: ""
    property bool subtext_warning: true

    function init() {
        // Call this function before .show()
        ok_button.setFocus(Enums.FocusDir.Right);
        subtext = "";
        dialog.height = 140;
        dialog.width = 300;
    }

    function setSubText(pk, pk_column_name, table_name) {
        // Call this function after .init()
        subtext = qsTr("Loading - Please wait");
        subtext_warning = true;
        dialog.height = 180;
        dialog.width = 330;

        Qt.callLater(function() {
            const res = database.deleteEntryAffectedRowCounts(pk, pk_column_name, table_name);
            const error_msg = res["error_msg"];
            const connections_count = res["connections"];
            const derivatives_count = res["total_entries"] - 1;

            if(error_msg === undefined || error_msg.length > 0 || connections_count === undefined || derivatives_count === undefined) {
                let subtext_str = qsTr("Failed to fetch affected entries");
                if(res["error_msg"] !== undefined) subtext_str += ": " + res["error_msg"];

                setStatusMessage(subtext_str, Enums.StatusMsgLvl.Err);
                delete_dialog.subtext = subtext_str;
                subtext_warning = true;
            } else if(connections_count + derivatives_count > 0) {
                let subtext_str = qsTr("Deleting this entry will also result in a deletion of") + ":\n";

                if(connections_count > 0) subtext_str += connections_count + " " + ((connections_count > 1) ? qsTr("connections") : qsTr("connection"));
                if(derivatives_count > 0) {
                    if(connections_count > 0 ) subtext_str += " " + qsTr("and") + " ";
                    
                    subtext_str += derivatives_count + " " + ((derivatives_count > 1) ? qsTr("derivatives") : qsTr("derivative"));
                }
                
                delete_dialog.subtext = subtext_str;
                subtext_warning = true;
            } else {
                delete_dialog.subtext = qsTr("Only this entry will be deleted.\nNo connections or derivatives for this entry exist.");
                subtext_warning = false;
            }
        
            dialog.height = 180;
            dialog.width = 330;
        });
    }

    Column
    {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4
        property int row_count: (subtext_item.visible) ? 3 : 2

        Text
        {
            text: dialog.text
            property double height_factor: (subtext_item.visible) ? 0.3 : 0.7
            height: parent.height * height_factor - (parent.spacing * (parent.row_count - 1))
            width: parent.width
            font.pointSize: fontSize_default
            font.family: fontFamily_default
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.bold: true
            lineHeight: height * 0.3
            lineHeightMode: Text.FixedHeight
            maximumLineCount: 3
            wrapMode: Text.Wrap
        }

        Item
        {
            id: subtext_item
            visible: dialog.subtext.length > 0
            height: parent.height * 0.5 - (parent.spacing * (parent.row_count - 1))
            width: parent.width

            InformationRect
            {
                id: subtext_information_rect
                anchors.fill: parent
                color: (subtext_warning) ? backgroundColorWarning : backgroundColorInformation
                multiline: true
                information_text: dialog.subtext
                text_font_size: fontSize_small
                text_font_family: fontFamily_small
            }
        }

        Text
        {
            text: qsTr("Do you want to proceed?")
            width: parent.width
            property double height_factor: (subtext_item.visible) ? 0.2 : 0.3
            height: parent.height * height_factor - (parent.spacing * (parent.row_count - 1))
            font.pointSize: fontSize_default
            font.family: fontFamily_default
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            textFormat: Text.RichText
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
                text: qsTr("Delete Entry")
                height: parent.height - anchors.bottomMargin
                width: (parent.width - parent.spacing) / 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                highlight_color: backgroundColorError
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                    else abort_button.setFocus(dir);
                }
                
                Component.onCompleted: setFocus(Enums.FocusDir.Right)

                onClicked:
                {
                    callback_function();
                    close();
                }
            }

            BasicButton
            {
                id: abort_button
                text: qsTr("Abort")
                height: parent.height - anchors.bottomMargin
                width: (parent.width - parent.spacing) / 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                hover_color: textColor
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) clicked();
                    else ok_button.setFocus(dir);
                }

                onClicked:
                {
                    close();
                    ok_button.setFocus(Enums.FocusDir.Right);
                }
            }
        }

    function callback_function() {}
}