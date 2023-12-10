import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle
{
    id: template_root

    color: "red"

    Text{
        id: template_text
        text: qsTr("Template")
    }
}