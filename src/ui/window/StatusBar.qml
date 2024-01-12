import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../types"

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
            color: {
                switch(status_message_level) {
                    case Enums.StatusMsgLvl.Default:
                        return "transparent";
                    case Enums.StatusMsgLvl.Info:
                        return backgroundColorNotification;
                    case Enums.StatusMsgLvl.Warn:
                        return backgroundColorWarning;
                    case Enums.StatusMsgLvl.Err:
                        return backgroundColorError;
                }
            }
            radius: 4

            MouseArea
            {
                anchors.fill: parent
                onClicked: if(status_message_level !== default_status_message_level) setDefaultStatusMessage();
            }

            Text
            {
                id: db_path_text
                anchors.fill: parent
                anchors.margins: 4
                font.pointSize: textSizeSmall
                color: {
                    switch(status_message_level) {
                        case Enums.StatusMsgLvl.Default:
                            return text_color;
                        default:
                            return getContrastColor(parent.color);
                    }
                }
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideLeft
                text: {
                    switch(status_message_level) {
                        case Enums.StatusMsgLvl.Default:
                            return status_message;
                        case Enums.StatusMsgLvl.Info:
                            return qsTr("Status") + ": " + status_message;
                        case Enums.StatusMsgLvl.Warn:
                            return qsTr("Warning") + ": " + status_message;
                        case Enums.StatusMsgLvl.Err:
                            return qsTr("Error") + ": " + status_message;
                    }
                }
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