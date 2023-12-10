import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "window"
import "tabs"

ApplicationWindow
{
    id: rootWindow
    width: 400
    height: 600
    visible: true
    color: backgroundColor

    // Colors
    property color backgroundColor: "#000000"
    property color backgroundColor1: "#303030"
    property color backgroundColor2: "#535353"
    property color backgroundColor3: "#9f9f9f"
    property color highlightColor: "#00EF00"
    property color textColor: "#ffffff"

    // Text size
    property real textSize: 12.0
    property real textSizeSmall: 10.0

    // Menu Bar
    menuBar: MenuBar { id: menu_bar }

    // Status Bar
    footer: StatusBar
    {
        width: parent.width
        height: menu_bar.height
    }

    // Contents
    Rectangle
    {
        anchors.fill: parent
        color: "blue"
        visible: false
    }

    TabBarMain
    {
        anchors.fill: parent
    }
}