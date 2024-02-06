import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Universal


ApplicationWindow
{
    id: dialog
    title: description
    color: "transparent"
    flags: Qt.SplashScreen
    modality: Qt.ApplicationModal
    minimumWidth: 150
    minimumHeight: 150
    width: 150
    height: 150
    required property string description

    Rectangle
    {
        id: main_rect
        color: backgroundColor2
        border.color: backgroundColor3
        border.width: 1
        radius: 8
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: dialog.close()

        Column
        {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8
            property int row_count: 3

            BusyIndicator
            {
                id: control
                width: parent.width
                height: (parent.height * 0.8) - (parent.spacing * parent.row_count)
                Universal.accent: highlightColor
            }

            Text
            {
                text: description
                width: parent.width
                height: parent.height * 0.1
                font.pointSize: textSize
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.bold: true
            }

            Text
            {
                text: qsTr("Please Wait.")
                width: parent.width
                height: parent.height * 0.1
                font.pointSize: textSize
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.bold: false
            }
        }
    }

    MouseArea
    {
        anchors.fill: parent
        cursorShape: Qt.WaitCursor
        acceptedButtons: Qt.NoButton
    }
}