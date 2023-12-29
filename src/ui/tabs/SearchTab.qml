import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle
{
    id: tab_main
    color: "transparent"
    border.color: backgroundColor3
    border.width: 1
    radius: 4

    Text
    {
        id: template_text
        text: qsTr("Search Tab")
        color: textColor
    }
}