import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"


ApplicationWindow
{
    id: dialog
    title: "Do you want to proceed?"
    color: backgroundColor1
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 140
    width: 300
    height: 140

    Column
    {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Text
        {
            text: qsTr("<p><b>The specified entry<br>with its derivates and connections<br>will be deleted.</b></p>")
            height: parent.height * 0.7
            width: parent.width
            font.pointSize: textSize
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            textFormat: Text.RichText
        }

        Text
        {
            text: qsTr("<p><i>Do you want to proceed?</i></p>")
            width: parent.width
            height: parent.height * 0.3 - parent.spacing
            font.pointSize: textSize
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            textFormat: Text.RichText
        }
    }

    footer:
        Row
        {
            height: 27
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            focus: true
            Keys.onReturnPressed: ok_button.clicked()
            Keys.onEscapePressed: abort_button.clicked()

            BasicButton
            {
                id: ok_button
                text: qsTr("Delete Entry")
                height: parent.height - anchors.bottomMargin
                width: (parent.width - parent.spacing) / 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                highlight_color: backgroundColorError
                selected: parent.focus

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

                onClicked:
                {
                    close();
                }
            }
        }

    function callback_function() {}
}