import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../types"

CheckBox
{
    id: checkbox_root
    checked: true
    enabled: true
    property color highlight_color: highlightColor
    property color background_color_hover: backgroundColor2
    property color background_color: "transparent"

    Keys.onReturnPressed: toggle();
    Keys.onEscapePressed: nextFocus(Enums.FocusDir.Close);
    Keys.onTabPressed: nextFocus(Enums.FocusDir.Right);
    Keys.onBacktabPressed: nextFocus(Enums.FocusDir.Left);
    Keys.onUpPressed: nextFocus(Enums.FocusDir.Up);
    Keys.onDownPressed: nextFocus(Enums.FocusDir.Down);
    Keys.onLeftPressed: nextFocus(Enums.FocusDir.Left);
    Keys.onRightPressed: nextFocus(Enums.FocusDir.Right);

    function setFocus(dir) {
        if(!enabled) {
            nextFocus(dir);
            return;
        }

        forceActiveFocus();
        focusSet();
    }

    signal nextFocus(dir: int)
    signal focusSet()

    indicator: Rectangle
    {
        implicitWidth: parent.height - 8
        implicitHeight: parent.height - 8
        x: parent.leftPadding
        y: parent.height / 2 - height / 2
        radius: 4
        color: (checkbox_root.enabled) ? backgroundColor3 : backgroundColor2
        border.color: (checkbox_mouse_area.containsMouse && checkbox_root.enabled) ? highlight_color : color
        property bool checked: parent.checked

        Rectangle
        {
            width: parent.width - 8
            height: parent.height - 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            radius: 4
            color: highlight_color
            visible: parent.checked && checkbox_root.enabled
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
        font.pointSize: fontSize_default
        font.family: fontFamily_default
        color: {
            if(!checkbox_root.enabled) return textColor1;
            else if(parent.checked) return highlight_color;
            else return textColor;
        }
        font.italic: !parent.enabled
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle
    {
        anchors.fill: parent
        color: (checkbox_mouse_area.containsMouse && checkbox_root.enabled) ? parent.background_color_hover : parent.background_color
        border.color: (checkbox_root.activeFocus) ? highlightColor : color
        border.width: 1
        radius: 4
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