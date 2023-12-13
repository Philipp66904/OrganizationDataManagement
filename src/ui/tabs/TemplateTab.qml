import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"

Rectangle
{
    id: template_root

    color: "transparent"

    Text
    {
        id: template_text
        text: qsTr("Template")
    }

    Table
    {
        anchors.fill: parent
    }
}