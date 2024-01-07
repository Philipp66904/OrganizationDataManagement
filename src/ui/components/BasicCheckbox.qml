import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

CheckBox
{
    id: checkbox_root
    checked: true
    property color highlight_color: highlightColor

    indicator: Rectangle
    {
        implicitWidth: parent.height
        implicitHeight: parent.height
        x: parent.leftPadding
        y: parent.height / 2 - height / 2
        radius: 4
        color: backgroundColor3
        border.color: (checkbox_mouse_area.containsMouse) ? highlight_color : color
        property bool checked: parent.checked

        Rectangle
        {
            width: parent.width - 8
            height: parent.height - 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            radius: 4
            color: highlight_color
            visible: parent.checked
        }

        MouseArea
        {
            anchors.fill: parent
            enabled: false
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.NoButton
        }
    }

    contentItem: Text
    {
        text: parent.text
        leftPadding: parent.indicator.width + parent.spacing
        font.pointSize: textSize
        color: (parent.checked) ? highlight_color : textColor
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    MouseArea
    {
        id: checkbox_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        enabled: true
        acceptedButtons: Qt.NoButton
    }
}