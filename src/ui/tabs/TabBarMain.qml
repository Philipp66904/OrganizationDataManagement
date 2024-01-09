import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"

Rectangle
{
    id: tab_bar_main
    color: backgroundColor1

    Column
    {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        Rectangle
        {
            id: tab_bar_rect
            width: parent.width
            height: 30
            color: backgroundColor2
            radius: 8

            Row
            {
                id: tab_bar_row
                anchors.fill: parent
                spacing: 8
                property int item_count: 4

                TabBarButton
                {
                    id: search_tab_button
                    height: tab_bar_row.height
                    width: (tab_bar_row.width - (tab_bar_row.spacing * (tab_bar_row.item_count - 1))) / tab_bar_row.item_count
                    bar_text: qsTr("Search")
                    highlighted: (stack_layout.currentIndex === identifier) ? true : false
                    property int identifier: 0

                    onClicked: stack_layout.currentIndex = identifier
                }

                TabBarButton
                {
                    id: organization_tab_button
                    height: tab_bar_row.height
                    width: (tab_bar_row.width - (tab_bar_row.spacing * (tab_bar_row.item_count - 1))) / tab_bar_row.item_count
                    bar_text: qsTr("Organization")
                    highlighted: (stack_layout.currentIndex === identifier) ? true : false
                    property int identifier: 1

                    onClicked: stack_layout.currentIndex = identifier
                }

                TabBarButton
                {
                    id: person_tab_button
                    height: tab_bar_row.height
                    width: (tab_bar_row.width - (tab_bar_row.spacing * (tab_bar_row.item_count - 1))) / tab_bar_row.item_count
                    bar_text: qsTr("Person")
                    highlighted: (stack_layout.currentIndex === identifier) ? true : false
                    property int identifier: 2

                    onClicked: stack_layout.currentIndex = identifier
                }

                TabBarButton
                {
                    id: address_tab_button
                    height: tab_bar_row.height
                    width: (tab_bar_row.width - (tab_bar_row.spacing * (tab_bar_row.item_count - 1))) / tab_bar_row.item_count
                    bar_text: qsTr("Address")
                    highlighted: (stack_layout.currentIndex === identifier) ? true : false
                    property int identifier: 3

                    onClicked: stack_layout.currentIndex = identifier
                }
            }
        }

        StackLayout
        {
            id: stack_layout
            height: parent.height - tab_bar_row.height - parent.spacing
            width: parent.width
            currentIndex: 0
            SearchTab {}
            OrganizationsTab {}
            PersonsTab {}
            AddressesTab {}
        }
    }
}