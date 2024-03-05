import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

Rectangle
{
    id: information_text_rect
    color: backgroundColorInformation
    radius: 8
    border.color: textColor
    border.width: 1
    visible: true
    required property string information_text
    property bool multiline: false

    Row
    {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8

        Image
        {
            id: information_image
            height: parent.height
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: "../res/svg/information_symbol.svg"
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 100
            sourceSize.height: 100
        }

        Text
        {
            id: information_text
            text: information_text_rect.information_text
            visible: parent.visible
            width: parent.width - information_image.width - parent.spacing
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: fontSize_default
            font.family: fontFamily_default
            color: textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            wrapMode: (multiline) ? Text.Wrap : Text.NoWrap
        }
    }
}