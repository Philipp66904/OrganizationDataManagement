import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import Qt.labs.platform

Rectangle
{
    id: color_selection_rectangle
    color: (root_mouse_area.containsMouse) ? backgroundColor2 : "transparent"
    radius: 4
    required property string description_text
    required property color selected_color

    signal newColor(new_color: color)

    MouseArea
    {
        id: root_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    ColorDialog
    {
        id: color_dialog
        onColorChanged: selected_color = color
    }

    Row
    {
        id: color_selection_row
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8
        property int column_count: 2

        Text
        {
            id: color_selection_description_text
            text: description_text
            height: parent.height
            width: (parent.width - ((parent.column_count - 1) * parent.spacing)) / 2
            font.pointSize: fontSize_default
            font.family: fontFamily_default
            color: textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Rectangle
        {
            id: color_selection_color_rect
            height: parent.height
            width: (parent.width - ((parent.column_count - 1) * parent.spacing)) / 2
            color: selected_color
            border.color: getContrastColor(color)
            border.width: 1
            radius: 4

            Text
            {
                id: color_selection_color_text
                text: selected_color
                anchors.fill: parent
                anchors.margins: 4
                font.pointSize: fontSize_default
                font.family: fontFamily_default
                color: getContrastColor(parent.color)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            MouseArea
            {
                id: color_selection_mouse_area
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    color_dialog.currentColor = selected_color;
                    color_dialog.open();
                }
            }
        }
    }
}