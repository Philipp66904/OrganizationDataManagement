import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle
{
    id: simple_button_rect
    radius: 4
    color: (simple_button_mouse_area.containsMouse) ? backgroundColor2 : "transparent"

    signal clicked()
    required property string simple_button_image_src

    MouseArea
    {
        id: simple_button_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: simple_button_rect.clicked()
    }

    Image
    {
        id: simple_button_image
        height: (simple_button_mouse_area.pressed) ? parent.height - 12 : parent.height - 8
        width: height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: (simple_button_mouse_area.pressed) ? 6 : 4
        source: simple_button_image_src
        fillMode: Image.PreserveAspectFit
        sourceSize.width: 100
        sourceSize.height: 100
    }
}