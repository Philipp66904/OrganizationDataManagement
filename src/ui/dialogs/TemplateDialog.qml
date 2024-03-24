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
    minimumHeight: 120
    width: 300
    height: 120

    required property string title_text
    required property string main_text
    required property string sub_text
    required property string ok_text
    required property string abort_text

    property bool show_abort_button: true

    function init() {
        // Call this function before .show()
        ok_button.setFocus(Enums.FocusDir.Right);
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
            height: parent.height * 0.75 - parent.spacing
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

        Text
        {
            text: sub_text
            height: parent.height * 0.25 - parent.spacing
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

            BasicButton
            {
                id: ok_button
                text: ok_text
                height: parent.height - anchors.bottomMargin
                width: (show_abort_button) ? (parent.width - parent.spacing) / 2 : parent.width
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
                visible: show_abort_button
                text: abort_text
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