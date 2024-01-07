import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle  // statusbar in the window's footer
{
    id: statusbar
    color: "transparent"

    Rectangle
    {
        id: separator
        width: parent.width
        height: 1
        anchors.bottom: parent.top
        color: backgroundColor3
    }

    property color text_color: (statusbar_mouse_area.containsMouse) ? textColor : backgroundColor3
    Behavior on text_color {
        enabled: true

        ColorAnimation
        {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    MouseArea
    {
        id: statusbar_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Row
    {
        id: statusbar_row
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        property int row_items_count: 3
        property int spacing_width: 1

        Component
        {
            id: spacing_component

            Rectangle
            {
                height: statusbar_row.height
                width: statusbar_row.spacing_width
                color: backgroundColor3
                radius: 1
            }
        }

        Rectangle
        {
            height: parent.height
            width: ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count
            color: (error_message.length > 0) ? backgroundColorError : "transparent"

            Text
            {
                id: db_path_text
                anchors.fill: parent
                anchors.margins: 4
                font.pointSize: textSizeSmall
                color: textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: (error_message.length > 0) ? qsTr("Status: ") + error_message : ""
            }
        }

        Loader { sourceComponent: spacing_component }

        Rectangle
        {
            height: parent.height
            width: ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count
            color: "transparent"

            Text
            {
                id: saved_date_text
                anchors.fill: parent
                anchors.margins: 4
                font.pointSize: textSizeSmall
                color: text_color
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: "Saved: " + saved_date
            }
        }

        Loader { sourceComponent: spacing_component }

        Rectangle
        {
            height: parent.height
            width: ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count
            color: "transparent"

            Text
            {
                id: created_date_text
                anchors.fill: parent
                anchors.margins: 4
                font.pointSize: textSizeSmall
                color: text_color
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: "Created: " + created_date
            }
        }
    }
}