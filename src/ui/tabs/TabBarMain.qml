import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle
{
    id: tab_bar_main
    color: "transparent"

    Column
    {
        anchors.fill: parent
        spacing: 8

        TabBar {
            id: bar
            width: parent.width
            height: 40
            TabButton {
                text: qsTr("Home")
            }
            TabButton {
                text: qsTr("Discover")
            }
            TabButton {
                text: qsTr("Activity")
            }
        }

        StackLayout {
            height: parent.height - bar.height - parent.spacing
            width: parent.width
            currentIndex: bar.currentIndex
            Item {
                id: homeTab

                Rectangle{
                    anchors.fill: parent
                    color: "blue"
                }

                Text{
                    text: qsTr("1")
                }
            }
            Item {
                id: discoverTab

                Rectangle{
                    anchors.fill: parent
                    color: "blue"
                }

                Text{
                    text: qsTr("2")
                }
            }
            Item {
                id: activityTab

                Rectangle{
                    anchors.fill: parent
                    color: "blue"
                }

                Text{
                    text: qsTr("3")
                }
            }
        }
    }
}