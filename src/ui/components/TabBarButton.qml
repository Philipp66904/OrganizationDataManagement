import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../types"

Rectangle
{
    id: bar_rect
    required property string bar_text
    required property bool highlighted
    property bool hover: (bar_mouse_area.containsMouse || activeFocus) ? true : false
    property color selected_color: (highlighted) ? highlightColor : textColor
    property bool selected: activeFocus
    property bool button_enabled: true
    property bool containsMouse: bar_mouse_area.containsMouse

    signal clicked()
    signal nextFocus(dir: int)

    function setFocus(dir) {
        if(button_enabled) {
            bar_rect.forceActiveFocus();
            clicked();
        } else {
            nextFocus(dir);
        }
    }

    Keys.onReturnPressed: clicked();
    Keys.onEscapePressed: nextFocus(Enums.FocusDir.Close);
    Keys.onTabPressed: nextFocus(Enums.FocusDir.Right);
    Keys.onBacktabPressed: nextFocus(Enums.FocusDir.Left);
    Keys.onUpPressed: nextFocus(Enums.FocusDir.Up);
    Keys.onDownPressed: nextFocus(Enums.FocusDir.Down);
    Keys.onLeftPressed: nextFocus(Enums.FocusDir.Left);
    Keys.onRightPressed: nextFocus(Enums.FocusDir.Right)

    Gradient {
        id: selected_gradient
        GradientStop { position: 0.0; color: selected_color }
        GradientStop { position: 0.15; color: "transparent" }
        GradientStop { position: 0.85; color: "transparent" }
        GradientStop { position: 1.0; color: selected_color }
    }

    color: "transparent"
    gradient: (selected && button_enabled && !containsMouse) ? selected_gradient : null
    border.color:
    {
        if(highlighted) return highlightColor;
        else if(hover) return textColor;
        else return "transparent";
    }
    border.width: 1
    radius: 8

    Text
    {
        text: bar_text
        anchors.fill: parent
        anchors.margins: 4
        font.pointSize: fontSize_default
        color: (parent.highlighted) ? highlightColor : textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    MouseArea
    {
        id: bar_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        enabled: button_enabled
        cursorShape: Qt.PointingHandCursor

        onClicked:
        {
            bar_rect.clicked();
            bar_rect.setFocus(Enums.FocusDir.Right);
        }
    }
}