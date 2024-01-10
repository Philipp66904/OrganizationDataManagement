import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../types"

Rectangle
{
    id: button_root_rect
    property string text: ""
    property var text_point_size: textSizeSmall
    property color highlight_color: highlightColor
    property color hover_color: highlight_color
    property color selected_color: hover_color
    property color border_default_color: backgroundColor3
    property bool selected: activeFocus
    property bool button_enabled: true
    property bool containsMouse: button_mouse_area.containsMouse
    signal clicked()
    signal pressed()
    signal doubleClicked()
    signal nextFocus(dir: int)

    Keys.onReturnPressed: clicked();
    Keys.onEscapePressed: nextFocus(Enums.FocusDir.Close);
    Keys.onTabPressed: nextFocus(Enums.FocusDir.Right);
    Keys.onBacktabPressed: nextFocus(Enums.FocusDir.Left);
    Keys.onUpPressed: nextFocus(Enums.FocusDir.Up);
    Keys.onDownPressed: nextFocus(Enums.FocusDir.Down);
    Keys.onLeftPressed: nextFocus(Enums.FocusDir.Left);
    Keys.onRightPressed: nextFocus(Enums.FocusDir.Right);

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
        if(button_enabled === false) return "transparent";
        else if(button_mouse_area.pressed) return highlight_color;
        else if(containsMouse) return hover_color;
        else if(selected) return selected_color;
        else border_default_color;
    }
    border.width: 1
    radius: 8

    function setFocus(dir) {
        if(visible && button_enabled) {
            forceActiveFocus();
        }
        else nextFocus(dir);
    }

    onButton_enabledChanged: if(!button_enabled) nextFocus(Enums.FocusDir.Left)

    Text
    {
        id: button_text
        text: button_root_rect.text
        anchors.fill: parent
        anchors.margins: 4
        font.pointSize: (button_mouse_area.pressed) ? textSizeSmall : textSize
        color:
        {
            if(button_enabled === false) return textColor1;
            else if(button_mouse_area.pressed) return highlight_color;
            else if(containsMouse) return hover_color;
            else textColor;
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    MouseArea
    {
        id: button_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        enabled: button_enabled
        cursorShape: (enabled) ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            button_root_rect.clicked();
        }

        onPressed: {
            button_root_rect.pressed()
        }

        onDoubleClicked: {
            button_root_rect.doubleClicked();
        }
    }
}