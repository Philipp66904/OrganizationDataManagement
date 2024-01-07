import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle
{
    id: bar_rect
    required property string bar_text
    required property bool highlighted
    property bool hover: (bar_mouse_area.containsMouse) ? true : false

    signal clicked()

    color: "transparent"
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
        font.pointSize: textSize
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
        cursorShape: Qt.PointingHandCursor

        onClicked:
        {
            bar_rect.clicked();
        }
    }
}