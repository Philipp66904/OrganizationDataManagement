import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.15
import QtPositioning 5.8

Window
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
}