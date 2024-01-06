import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import tablemodule 1.0

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

    property var organization_search_res: []
    property var person_search_res: []
    property var address_search_res: []

    // Signals
    signal resetSearch()
    signal softResetSearch()
    signal updateSearch()

    // Signal handler
    onResetSearch: {
        load_data();
        updateSearch();
        softResetSearch();
    }

    onSoftResetSearch: {
        load_data_soft();
    }

    onUpdateSearch: {
        const organization_search_selection = organization_button_selection.getListModel();
        const person_search_selection = person_button_selection.getListModel();
        const address_search_selection = address_button_selection.getListModel();

        organization_search_res = database.search("organization", search_term,
            selected_organization_id, selected_person_id, selected_address_id,
            organization_search_selection);

        person_search_res = database.search("person", search_term,
            selected_organization_id, selected_person_id, selected_address_id,
            person_search_selection);
        
        address_search_res = database.search("address", search_term,
            selected_organization_id, selected_person_id, selected_address_id,
            address_search_selection);
    }

    Component.onCompleted: resetSearch()

    // Connection
    Connections {
        target: database
        function onDataChanged() {
            updateSearch();
            softResetSearch();
        }

        function onDatabaseLoaded(db_path) {
            resetSearch();
        }
    }

    function load_data() {
        search_term = "";
        organization_search_res = [];
        person_search_res = [];
        address_search_res = [];
    }

    function load_data_soft() {
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
        property var table_column_height: (height - separator.height - (spacing * (column_count - 1))) * 0.5 - 4

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
                    let h = module_height * 15;
                    h += spacing * (row_count - 1);  // spacing
                    return h;
                }
                spacing: 8

                property var row_count: 7
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

                    function init() {
                        const organization_data = database.getOrganizationConnection(-1);
                        combo_selection_organization.load_data(organization_data);
                        selected_organization_id = combo_selection_organization.selected_index;
                    }

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            combo_selection_organization.init();
                        }

                        function onSoftResetSearch() {
                            combo_selection_organization.init();
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

                    function init() {
                        const person_data = database.getPersonConnection(-1);
                        combo_selection_person.load_data(person_data);
                        selected_person_id = combo_selection_person.selected_index;
                    }

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            combo_selection_person.init();
                        }

                        function onSoftResetSearch() {
                            combo_selection_person.init();
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

                    function init() {
                        const address_data = database.getAddressConnection(-1);
                        combo_selection_address.load_data(address_data);
                        selected_address_id = combo_selection_address.selected_index;
                    }

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            combo_selection_address.init();
                        }

                        function onSoftResetSearch() {
                            combo_selection_address.init();
                        }
                    }
                }

                ButtonSelection
                {
                    id: organization_button_selection
                    width: parent.width
                    height: search_parameter_column.module_height * 3
                    table_name: "organization"
                    description_text: qsTr("Search in Organization properties:")

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            organization_button_selection.init();
                        }
                    }

                    onUpdateListModel: {
                        updateSearch();
                    }
                }

                ButtonSelection
                {
                    id: person_button_selection
                    width: parent.width
                    height: search_parameter_column.module_height * 3
                    table_name: "person"
                    description_text: qsTr("Search in Person properties:")

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            person_button_selection.init();
                        }
                    }

                    onUpdateListModel: {
                        updateSearch();
                    }
                }

                ButtonSelection
                {
                    id: address_button_selection
                    width: parent.width
                    height: search_parameter_column.module_height * 3
                    table_name: "address"
                    description_text: qsTr("Search in Address properties:")

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            address_button_selection.init();
                        }
                    }

                    onUpdateListModel: {
                        updateSearch();
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

        Column
        {
            id: table_column
            width: parent.width
            height: main_column.table_column_height
            spacing: 4

            property int row_count: 2
            property var tab_row_height: (height - ((row_count - 1) * spacing)) * 0.1
            property var table_height: (height - ((row_count - 1) * spacing)) * 0.9

            Row
            {
                id: tab_row
                width: parent.width - 8
                height: table_column.tab_row_height
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                property int column_count: 4
                property var module_width: (width - ((column_count - 1) * spacing)) / column_count

                Text
                {
                    text: qsTr("Search Results:")
                    width: tab_row.module_width
                    height: parent.height
                    font.pointSize: textSize
                    color: backgroundColor3
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                TabBarButton
                {
                    id: organization_table_search_results_button
                    width: tab_row.module_width
                    height: parent.height
                    bar_text: qsTr("Organization")
                    highlighted: (search_result_table_stack_layout.currentIndex === stack_layout_index)
                    property int stack_layout_index: 0

                    onClicked:
                    {
                        search_result_table_stack_layout.currentIndex = stack_layout_index;
                    }
                }

                TabBarButton
                {
                    id: person_table_search_results_button
                    width: tab_row.module_width
                    height: parent.height
                    bar_text: qsTr("Person")
                    highlighted: (search_result_table_stack_layout.currentIndex === stack_layout_index)
                    property int stack_layout_index: 1

                    onClicked:
                    {
                        search_result_table_stack_layout.currentIndex = stack_layout_index;
                    }
                }

                TabBarButton
                {
                    id: address_table_search_results_button
                    width: tab_row.module_width
                    height: parent.height
                    bar_text: qsTr("Address")
                    highlighted: (search_result_table_stack_layout.currentIndex === stack_layout_index)
                    property int stack_layout_index: 2

                    onClicked:
                    {
                        search_result_table_stack_layout.currentIndex = stack_layout_index;
                    }
                }
            }

            StackLayout
            {
                id: search_result_table_stack_layout
                height: table_column.table_height
                width: parent.width - 8
                anchors.horizontalCenter: parent.horizontalCenter
                currentIndex: 0
            
                SearchResultTable
                {
                    id: organization_result_table

                    table_name: "organization"
                    search_res: organization_search_res

                    Connections {
                        target: tab_main
                        function onUpdateSearch() {
                            organization_result_table.load_data();
                        }
                    }

                    onEdit_button_clicked: function edit_button_clicked(pk) {
                        organization_edit_dialog.pk_id = pk;

                        let parent_id_tmp = database.getParentId(table_name, pk, "id");
                        if (parent_id_tmp < 0) parent_id_tmp = undefined;
                        organization_edit_dialog.parent_id = parent_id_tmp;
                        
                        organization_edit_dialog.show();
                        organization_edit_dialog.init_dialog();
                    }
                }

                SearchResultTable
                {
                    id: person_result_table

                    table_name: "person"
                    search_res: person_search_res

                    Connections {
                        target: tab_main
                        function onUpdateSearch() {
                            person_result_table.load_data();
                        }
                    }

                    onEdit_button_clicked: function edit_button_clicked(pk) {
                        person_edit_dialog.pk_id = pk;
                        person_edit_dialog.show();
                        person_edit_dialog.init_dialog();
                    }
                }

                SearchResultTable
                {
                    id: address_result_table

                    table_name: "address"
                    search_res: address_search_res

                    Connections {
                        target: tab_main
                        function onUpdateSearch() {
                            address_result_table.load_data();
                        }
                    }

                    onEdit_button_clicked: function edit_button_clicked(pk) {
                        address_edit_dialog.pk_id = pk;
                        address_edit_dialog.show();
                        address_edit_dialog.init_dialog();
                    }
                }
            }
        }
    }
}