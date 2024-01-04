import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../components"

Rectangle
{
    id: tab_main
    color: "transparent"
    border.color: backgroundColor3
    border.width: 1
    radius: 4

    // Variables
    property string search_term: ""
    property int selected_organization_id: -1
    property int selected_person_id: -1
    property int selected_address_id: -1

    onSelected_organization_idChanged: console.log("selected_organization_id:", selected_organization_id)
    onSelected_person_idChanged: console.log("selected_person_id:", selected_person_id)
    onSelected_address_idChanged: console.log("selected_address_id:", selected_address_id)

    // Signals
    signal resetSearch()
    signal updateSearch()

    // Connection
    Connections {
        target: database
        function onDataChanged() {
            load_data();
            resetSearch();
        }
    }

    function load_data() {
        search_term = "";
        selected_organization_id = -1;
        selected_person_id = -1;
        selected_address_id = -1;
    }

    Column
    {
        id: main_column
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 4
        property int column_count: 2
        property var search_parameter_scroll_view_height: (height - separator.height - (spacing * (column_count - 1))) * 0.5

        ScrollView
        {
            id: search_parameter_scroll_view
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 8
            height: main_column.search_parameter_scroll_view_height
            contentWidth: width
            contentHeight: search_parameter_column.height
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff  // actually not needed because of contentWidth: width, just to be safe

            Column
            {
                id: search_parameter_column
                width: parent.width
                height: {
                    let h = property_line_edit_search.height * 8;
                    h += spacing * row_count;  // spacing
                    return h;
                }
                spacing: 8

                property var row_count: 8
                property var row_height_count: 8.5
                property var module_height: (search_parameter_scroll_view.height - ((search_parameter_column.row_count - 1) * search_parameter_column.spacing)) / search_parameter_column.row_height_count

                PropertyLineEdit
                {
                    id: property_line_edit_search
                    width: parent.width
                    height: search_parameter_column.module_height * 1.5
                    description: qsTr("Search")
                    value: ""
                    derivate_value: ""
                    derivate_mode: false
                    required: false

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            property_line_edit_search.value = "";
                            search_term = "";
                        }
                    }

                    onNew_value: function new_value(value, derivate_flag) {
                        search_term = value;
                        updateSearch();
                    }
                }

                ComboSelection
                {
                    id: combo_selection_organization
                    width: parent.width
                    height: search_parameter_column.module_height * 1.5
                    description_text: qsTr("Search in Organization")
                    not_null: false

                    onSelected_indexChanged: {
                        selected_organization_id = combo_selection_organization.selected_index;
                        updateSearch();
                    }

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            const organization_data = database.getOrganizationConnection(-1);
                            combo_selection_organization.load_data(organization_data);
                            selected_organization_id = combo_selection_organization.selected_index;
                        }
                    }
                }

                ComboSelection
                {
                    id: combo_selection_person
                    width: parent.width
                    height: search_parameter_column.module_height * 1.5
                    description_text: qsTr("Search in Person")
                    not_null: false

                    onSelected_indexChanged: {
                        selected_person_id = combo_selection_person.selected_index;
                        updateSearch();
                    }

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            const person_data = database.getPersonConnection(-1);
                            combo_selection_person.load_data(person_data);
                            selected_person_id = combo_selection_person.selected_index;
                        }
                    }
                }

                ComboSelection
                {
                    id: combo_selection_address
                    width: parent.width
                    height: search_parameter_column.module_height * 1.5
                    description_text: qsTr("Search in Address")
                    not_null: false

                    onSelected_indexChanged: {
                        selected_address_id = combo_selection_address.selected_index;
                        updateSearch();
                    }

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            const address_data = database.getAddressConnection(-1);
                            combo_selection_address.load_data(address_data);
                            selected_address_id = combo_selection_address.selected_index;
                        }
                    }
                }

                Rectangle
                {
                    id: button_selection
                    width: parent.width
                    height: search_parameter_column.module_height * 3
                    color: (button_selection_focus_scope.focus) ? backgroundColor2 : backgroundColor
                    border.color: (button_selection_focus_scope.focus) ? highlightColor : backgroundColor3
                    border.width: 1
                    radius: 4

                    FocusScope
                    {
                        id: button_selection_focus_scope
                        anchors.fill: parent

                        Column
                        {
                            id: button_selection_column
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 8
                            property int row_count: 2

                            Text
                            {
                                id: button_organization_selection_description
                                text: qsTr("Organization:")
                                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_count
                                width: parent.width
                                font.pointSize: textSize
                                color: backgroundColor3
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Row
                            {
                                id: button_organization_selection_row
                                spacing: 8
                                property int button_count: 3
                                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_count
                                width: parent.width

                                // TODO create checkboxes dynamically based on the database
                                // TODO store states in global variables

                                BasicCheckbox
                                {
                                    id: checkbox_1
                                    text: qsTr("name")
                                    height: parent.height
                                    width: (parent.width - ((parent.button_count - 1) * parent.spacing)) / parent.button_count

                                    Connections {
                                        target: tab_main
                                        function onResetSearch() {
                                            checkbox_1.checked = true;
                                        }
                                    }
                                }

                                BasicCheckbox
                                {
                                    id: checkbox_2
                                    text: qsTr("note")
                                    height: parent.height
                                    width: (parent.width - ((parent.button_count - 1) * parent.spacing)) / parent.button_count

                                    Connections {
                                        target: tab_main
                                        function onResetSearch() {
                                            checkbox_2.checked = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle
        {
            id: separator
            height: 1
            width: parent.width - (tab_main.border.width * 2)
            color: backgroundColor1
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}