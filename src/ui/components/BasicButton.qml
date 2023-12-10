import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle
{
    id: button_root_rect
    property var text: ""
    property var text_point_size: textSizeSmall
    property var highlight_color: highlightColor
    property bool containsMouse: button_mouse_area.containsMouse
    signal clicked()
    signal pressed()

    color: backgroundColor
    border.color:
    {
        if(button_mouse_area.pressed) return highlight_color;
        else if(containsMouse) return highlight_color;
        else backgroundColor2;
    }
    border.width: 1
    radius: 8

    Text
    {
        id: button_text
        text: button_root_rect.text
        anchors.fill: parent
        anchors.margins: 4
        font.pointSize: (button_mouse_area.pressed) ? textSizeSmall : textSize
        color:
        {
            if(button_mouse_area.pressed) return highlight_color;
            else if(containsMouse) return highlight_color;
            else backgroundColor3;
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

        onClicked:
        {
            button_root_rect.clicked();
        }

        onPressed:
        {
            button_root_rect.pressed()
        }
    }
}