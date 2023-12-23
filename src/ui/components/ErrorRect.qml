import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

Rectangle
{
    id: err_text_rect
    color: backgroundColorError
    radius: 8
    border.color: textColor
    border.width: 1
    visible: true
    required property string error_text

    Text
    {
        id: err_text
        anchors.fill: parent
        anchors.margins: 4
        text: err_text_rect.error_text
        visible: parent.visible
        font.pointSize: textSize
        color: textColor
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}