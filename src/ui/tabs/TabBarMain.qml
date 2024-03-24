import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"
import "../types"

Rectangle
{
    id: tab_bar_main
    color: backgroundColor1

    function setFocus(dir) {
        if(stack_layout.currentIndex === 0) search_tab_button.setFocus(dir);
        else if(stack_layout.currentIndex === 1) organization_tab_button.setFocus(dir);
        else if(stack_layout.currentIndex === 2) person_tab_button.setFocus(dir);
        else if(stack_layout.currentIndex === 3) address_tab_button.setFocus(dir);
    }

    signal nextFocus(dir: int)

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
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_bar_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) tab_bar_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Right) organization_tab_button.setFocus(dir);
                        else stack_layout.setFocus(dir);
                    }

                    Component.onCompleted: setFocus(Enums.FocusDir.Right)

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
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_bar_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up) tab_bar_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Left) search_tab_button.setFocus(dir);
                        else if(dir === Enums.FocusDir.Right) person_tab_button.setFocus(dir);
                        else stack_layout.setFocus(dir);
                    }

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
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_bar_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up) tab_bar_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Left) organization_tab_button.setFocus(dir);
                        else if(dir === Enums.FocusDir.Right) address_tab_button.setFocus(dir);
                        else stack_layout.setFocus(dir);
                    }

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
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_bar_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up) tab_bar_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Left) person_tab_button.setFocus(dir);
                        else stack_layout.setFocus(dir);
                    }

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

            function setFocus(dir) {
                if(currentIndex === 0) search_tab.setFocus(dir);
                else if(currentIndex === 1) organizations_tab.setFocus(dir);
                else if(currentIndex === 2) persons_tab.setFocus(dir);
                else if(currentIndex === 3) addresses_tab.setFocus(dir);
            }

            SearchTab
            {
                id: search_tab
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) tab_bar_main.setFocus(dir);
                    else if(dir === Enums.FocusDir.Save) tab_bar_main.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) search_tab_button.setFocus(Enums.FocusDir.Right);
                    else tab_bar_main.nextFocus(dir);
                }
            }
            OrganizationsTab
            {
                id: organizations_tab
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) tab_bar_main.setFocus(dir);
                    else if(dir === Enums.FocusDir.Save) tab_bar_main.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) organization_tab_button.setFocus(Enums.FocusDir.Right);
                    else tab_bar_main.nextFocus(dir);
                }
            }
            PersonsTab
            {
                id: persons_tab
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) tab_bar_main.setFocus(dir);
                    else if(dir === Enums.FocusDir.Save) tab_bar_main.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) person_tab_button.setFocus(Enums.FocusDir.Right);
                    else tab_bar_main.nextFocus(dir);
                }
            }
            AddressesTab
            {
                id: addresses_tab
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Close) tab_bar_main.setFocus(dir);
                    else if(dir === Enums.FocusDir.Save) tab_bar_main.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) address_tab_button.setFocus(Enums.FocusDir.Right);
                    else tab_bar_main.nextFocus(dir);
                }
            }
        }
    }
}