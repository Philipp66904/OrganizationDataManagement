import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

Rectangle
{
    id: error_text_rect
    color: backgroundColorError
    radius: 8
    border.color: textColor
    border.width: 1
    visible: true
    required property string error_text

    Row
    {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        Image
        {
            id: error_image
            height: parent.height
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: "../res/svg/error_symbol.svg"
        }

        Text
        {
            id: error_text
            text: error_text_rect.error_text
            visible: parent.visible
            width: parent.width - error_image.width - parent.spacing
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: textSize
            color: textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}