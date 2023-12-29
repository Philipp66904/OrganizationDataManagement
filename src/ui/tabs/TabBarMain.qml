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
        anchors.margins: 4
        spacing: 4

        Row
        {
            id: tab_bar_row
            width: parent.width
            height: 30
            spacing: 8
            property int item_count: 4

            Component
            {
                id: bar_component

                Rectangle
                {
                    id: bar_rect
                    property int identifier: 0
                    property var bar_text: ""
                    property bool highlighted: (stack_layout.currentIndex === identifier) ? true : false
                    property bool hover: (bar_mouse_area.containsMouse) ? true : false

                    height: tab_bar_row.height
                    width: (tab_bar_row.width - (tab_bar_row.spacing * (tab_bar_row.item_count - 1))) / tab_bar_row.item_count
                    color:
                    {
                        if(highlighted) return backgroundColor1;
                        else return backgroundColor;
                    }
                    border.color:
                    {
                        if(highlighted) return highlightColor;
                        else if(hover) return textColor;
                        else return backgroundColor1;
                    }
                    border.width: 1
                    radius: 8

                    Text
                    {
                        text: bar_text
                        anchors.fill: parent
                        anchors.margins: 4
                        font.pointSize: textSize
                        color: (parent.highlighted) ? highlightColor : textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    MouseArea
                    {
                        id: bar_mouse_area
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked:
                        {
                            stack_layout.currentIndex = parent.identifier
                        }
                    }
                }
            }

            Loader { sourceComponent: bar_component; onLoaded: { item.identifier = 0; item.bar_text = "Search" } }
            Loader { sourceComponent: bar_component; onLoaded: { item.identifier = 1; item.bar_text = "Organizations" } }
            Loader { sourceComponent: bar_component; onLoaded: { item.identifier = 2; item.bar_text = "Addresses" } }
            Loader { sourceComponent: bar_component; onLoaded: { item.identifier = 3; item.bar_text = "Persons" } }
        }

        StackLayout {
            id: stack_layout
            height: parent.height - tab_bar_row.height - parent.spacing
            width: parent.width
            currentIndex: 0
            SearchTab {}
            OrganizationsTab {}
            AddressesTab {}
            PersonsTab {}
        }
    }
}