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
    color: backgroundColor
    flags: Qt.Dialog
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 90
    width: 300
    height: 90

    Column
    {
        anchors.fill: parent
        anchors.margins: 4

        Text
        {
            text: qsTr("The specified entry will be deleted.")
            width: parent.width
            font.pointSize: textSize
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Text
        {
            text: qsTr("Do you want to proceed?")
            width: parent.width
            font.pointSize: textSize
            color: textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    footer:
        Row
        {
            height: 25
            width: parent.width
            spacing: 8
            focus: true
            Keys.onReturnPressed: ok_button.clicked()
            Keys.onEscapePressed: abort_button.clicked()

            BasicButton
            {
                id: ok_button
                text: qsTr("Ok")
                height: parent.height
                width: (parent.width - parent.spacing) / 2
                highlight_color: highlightColor
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
                height: parent.height
                width: (parent.width - parent.spacing) / 2
                highlight_color: "#ff0000"

                onClicked:
                {
                    close();
                }
            }
        }

    function callback_function() {}
}