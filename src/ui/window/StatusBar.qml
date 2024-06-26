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
            property int overhang: 2
            height: parent.height + overhang * 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -overhang
            width:
            { 
                let res = ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count;
                
                if(status_message_level !== Enums.StatusMsgLvl.Default) res = res * 2;
                else res = res / 2;

                return res;
            }
            Behavior on width {
                enabled: true

                NumberAnimation
                {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
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
                enabled: (status_message_level !== default_status_message_level)
                cursorShape: (enabled) ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: if(status_message_level !== default_status_message_level) setDefaultStatusMessage();
            }

            Text
            {
                id: status_text
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                anchors.topMargin: 4 + parent.overhang
                anchors.bottomMargin: 4 + parent.overhang
                font.pointSize: fontSize_small
                font.family: fontFamily_small
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
            width: {
                let res = ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count;

                if(status_message_level !== Enums.StatusMsgLvl.Default) res = res * 0.5;
                else res = res * 1.25;

                return res;
            }
            Behavior on width {
                enabled: true

                NumberAnimation
                {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            color: "transparent"

            Text
            {
                id: saved_date_text
                anchors.fill: parent
                anchors.margins: 4
                font.pointSize: fontSize_small
                font.family: fontFamily_small
                color: text_color
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: qsTr("Saved: ") + saved_date
            }
        }

        Loader { sourceComponent: spacing_component }

        Rectangle
        {
            height: parent.height
            width: {
                let res = ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count;
                
                if(status_message_level !== Enums.StatusMsgLvl.Default) res = res * 0.5;
                else res = res * 1.25;

                return res;
            }
            Behavior on width {
                enabled: true

                NumberAnimation
                {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            color: "transparent"

            Text
            {
                id: created_date_text
                anchors.fill: parent
                anchors.margins: 4
                font.pointSize: fontSize_small
                font.family: fontFamily_small
                color: text_color
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: qsTr("Created: ") + created_date
            }
        }
    }
}