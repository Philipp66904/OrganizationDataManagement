import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

MenuBar  // MenuBar shown in the window's header
    {
        id: menu_bar
        property int radius: 8

        Component
        {
            // component used for customizing the menu separator
            id: menu_separator_component

            Rectangle
            {
                implicitWidth: parent.width
                implicitHeight: 1
                color: backgroundColor1
            }
        }

        Component
        {
            // component used for customizing the menu background
            id: menu_background_component

            Rectangle
            {
                color: backgroundColor
                border.color: backgroundColor1
                border.width: 1
                radius: menu_bar.radius
                implicitWidth: 200
                implicitHeight: 40
            }
        }

        Component
        {
            // component used for customizing the action's text
            id: action_text_customization_component
            
            Text 
            {
                leftPadding: menuItem.indicator.width
                rightPadding: menuItem.arrow.width
                text: menuItem.text
                font.pointSize: textSizeSmall
                color: menuItem.highlighted ? highlightColor : textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Menu 
        {
            title: qsTr("File")
            background: Loader { sourceComponent: menu_background_component }
            delegate: MenuItem {
                id: menuItem
                implicitWidth: 200
                implicitHeight: 40

                contentItem: Text {
                    leftPadding: menuItem.indicator.width
                    rightPadding: menuItem.arrow.width
                    text: menuItem.text
                    font.pointSize: textSizeSmall
                    color: menuItem.highlighted ? highlightColor : textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    color: menuItem.highlighted ? backgroundColor1 : "transparent"
                    radius: menu_bar.radius
                    border.color: backgroundColor
                    border.width: 2
                }
            }

            Action { text: qsTr("New") }
            MenuSeparator 
            {
                contentItem: Loader { sourceComponent: menu_separator_component }
            }

            Action { text: qsTr("Open") }
            Action { text: qsTr("Open Recent") }

            MenuSeparator 
            {
                contentItem: Loader { sourceComponent: menu_separator_component }
            }
            Action { text: qsTr("Save") }
            Action { text: qsTr("Save As") }

            MenuSeparator 
            {
                contentItem: Loader { sourceComponent: menu_separator_component }
            }
            Action { text: qsTr("Close File") }

            MenuSeparator 
            {
                contentItem: Loader { sourceComponent: menu_separator_component }
            }
            Action { text: qsTr("Exit") }

        }

        Menu 
        {
            title: qsTr("Settings")
            background: Loader { sourceComponent: menu_background_component }
            delegate: MenuItem {
                id: menuItem
                implicitWidth: 200
                implicitHeight: 40

                contentItem: Text {
                    leftPadding: menuItem.indicator.width
                    rightPadding: menuItem.arrow.width
                    text: menuItem.text
                    font.pointSize: textSizeSmall
                    color: menuItem.highlighted ? highlightColor : textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    color: menuItem.highlighted ? backgroundColor1 : "transparent"
                    radius: menu_bar.radius
                    border.color: backgroundColor
                    border.width: 2
                }
            }

            Action { text: qsTr("Import") }
            Action { text: qsTr("Export") }
        }

        Menu 
        {
            title: qsTr("Help")
            background: Loader { sourceComponent: menu_background_component }
            delegate: MenuItem {
                id: menuItem
                implicitWidth: 200
                implicitHeight: 40

                contentItem: Text {
                    leftPadding: menuItem.indicator.width
                    rightPadding: menuItem.arrow.width
                    text: menuItem.text
                    font.pointSize: textSizeSmall
                    color: menuItem.highlighted ? highlightColor : textColor
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    color: menuItem.highlighted ? backgroundColor1 : "transparent"
                    radius: menu_bar.radius
                    border.color: backgroundColor
                    border.width: 2
                }
            }

            Action { text: qsTr("About") }

            MenuSeparator 
            {
                contentItem: Loader { sourceComponent: menu_separator_component }
            }
            Action { text: qsTr("Github") }
            Action { text: qsTr("Search for updates") }

            MenuSeparator 
            {
                contentItem: Loader { sourceComponent: menu_separator_component }
            }
            Action { text: qsTr("Licences") }
        }

        delegate: MenuBarItem {
            id: menuBarItem

            contentItem: Text {
                text: menuBarItem.text
                font.pointSize: textSize
                color: menuBarItem.highlighted ? highlightColor : textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 40
                implicitHeight: 30
                color: menuBarItem.highlighted ? backgroundColor1 : "transparent"
                border.color: backgroundColor
                border.width: 2
                radius: menu_bar.radius
            }
        }

        background: Rectangle {
            implicitWidth: 40
            implicitHeight: 30
            color: "transparent"

            Rectangle {
                color: backgroundColor1
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
            }
        }
    }