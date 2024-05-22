import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

Rectangle
{
    id: notification_text_rect
    color: backgroundColorNotification
    radius: 8
    border.color: textColor
    border.width: 1
    visible: true
    required property string notification_text
    property bool multiline: false
    property var text_font_size: fontSize_default
    property var text_font_family: fontFamily_default

    Row
    {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        Image
        {
            id: notification_image
            height: parent.height
            width: height
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            source: "../res/svg/check.svg"
        }

        Text
        {
            id: notification_text
            text: notification_text_rect.notification_text
            visible: parent.visible
            width: parent.width - notification_image.width - parent.spacing
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: text_font_size
            font.family: text_font_family
            color: getContrastColor(notification_text_rect.color)
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            wrapMode: (multiline) ? Text.Wrap : Text.NoWrap
        }
    }
}