import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import tablemodule 1.0

import "../components"
import "../types"

Rectangle
{
    id: tab_main
    color: backgroundColor1
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

    // Key Handling
    function setFocus(dir) {
        if(dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Right) property_line_edit_search.setFocus(dir);
        else search_result_table_stack_layout.setFocus(dir);
    }

    signal nextFocus(dir: int)

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

        function onSearchCacheChanged(tb_name) {
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
        property var max_distribution: 0.75
        property var min_distribution: 0.10
        property var distribution: 0.5
        property var search_parameter_scroll_view_height: (height - separator.height - (spacing * (column_count - 1))) * distribution
        property var search_parameter_scroll_view_default_height: (height - separator.height - (spacing * (column_count - 1))) * 0.5
        property var table_column_height: (height - separator.height - (spacing * (column_count - 1))) * (1 - distribution) - 4
        property var table_column_default_height: (height - separator.height - (spacing * (column_count - 1))) * (1 - 0.5) - 4

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

            function scrollTo(y_coord_top, y_coord_bot) {
                // Currently visible area
                const y_visible_top = ScrollBar.vertical.position * contentHeight;
                const y_visible_bot = y_visible_top + height;

                // Check if element is already visible
                if(y_coord_top >= y_visible_top && y_coord_bot <= y_visible_bot) {
                    return;  // Element already visible -> nothing to do
                }

                // Check if top of element is not visible
                if(y_coord_top < y_visible_top) {
                    const new_pos = y_coord_top / contentHeight;
                    ScrollBar.vertical.position = new_pos;
                    return;
                }

                // Check if bottom of element is not visible
                if(y_coord_bot > y_visible_bot) {
                    const new_pos = (y_coord_bot - height) / contentHeight;
                    ScrollBar.vertical.position = new_pos;
                    return;
                }
            }

            Column
            {
                id: search_parameter_column
                width: parent.width
                height: {
                    let h = module_height * 17;
                    h += spacing * (row_count - 1);  // spacing
                    return h;
                }
                spacing: 8

                property var row_count: 9
                property var row_height_count: Math.max(Math.round(main_column.height / 70), 3)
                property var module_height: (main_column.search_parameter_scroll_view_default_height - ((search_parameter_column.row_count - 1) * search_parameter_column.spacing)) / search_parameter_column.row_height_count

                PropertyLineEdit
                {
                    id: property_line_edit_search
                    width: parent.width
                    height: search_parameter_column.module_height * 1.5
                    description: qsTr("Search")
                    value: ""
                    derivative_value: ""
                    derivative_mode: false
                    required: false
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) tab_main.nextFocus(dir);
                        else combo_selection_organization.setFocus(dir);
                    }

                    onFocusSet: search_parameter_scroll_view.scrollTo(y, y + height);

                    Connections {
                        target: tab_main
                        function onResetSearch() {
                            property_line_edit_search.value = "";
                            search_term = "";
                        }
                    }

                    onNew_value: function new_value(value, derivative_flag) {
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
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) property_line_edit_search.setFocus(dir);
                        else combo_selection_person.setFocus(dir);
                    }

                    onFocusSet: search_parameter_scroll_view.scrollTo(y, y + height);

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
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) combo_selection_organization.setFocus(dir);
                        else combo_selection_address.setFocus(dir);
                    }

                    onFocusSet: search_parameter_scroll_view.scrollTo(y, y + height);

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
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) combo_selection_person.setFocus(dir);
                        else select_all_button.setFocus(dir);
                    }

                    onFocusSet: search_parameter_scroll_view.scrollTo(y, y + height);

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

                Rectangle
                {
                    id: selection_button_row_rect
                    width: parent.width
                    height: search_parameter_column.module_height * 1
                    color: "transparent"
                    radius: 8

                    Row
                    {
                        id: selection_button_row
                        anchors.fill: parent
                        spacing: 8
                        property int column_count: 3
                        property var button_width: (width - ((column_count - 1) * spacing)) / column_count

                        function setSelection(state) {
                            organization_button_selection.setButtonState(state);
                            person_button_selection.setButtonState(state);
                            address_button_selection.setButtonState(state);
                        }

                        BasicButton
                        {
                            id: select_all_button
                            width: selection_button_row.button_width
                            height: parent.height
                            text: qsTr("Select All")
                            hover_color: textColor
                            onNextFocus: function next_focus(dir) {
                                if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                                else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) combo_selection_address.setFocus(dir);
                                else if(dir === Enums.FocusDir.Right) unselect_all_button.setFocus(dir);
                                else organization_button_selection.setFocus(dir);
                            }

                            onFocusSet: search_parameter_scroll_view.scrollTo(selection_button_row_rect.y, selection_button_row_rect.y + selection_button_row_rect.height);

                            onClicked: {
                                selection_button_row.setSelection(1);
                            }
                        }

                        BasicButton
                        {
                            id: unselect_all_button
                            width: selection_button_row.button_width
                            height: parent.height
                            text: qsTr("Unselect All")
                            hover_color: textColor
                            onNextFocus: function next_focus(dir) {
                                if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                                else if(dir === Enums.FocusDir.Up) combo_selection_address.setFocus(dir);
                                else if(dir === Enums.FocusDir.Left) select_all_button.setFocus(dir);
                                else if(dir === Enums.FocusDir.Right) invert_selection_button.setFocus(dir);
                                else organization_button_selection.setFocus(dir);
                            }

                            onFocusSet: search_parameter_scroll_view.scrollTo(selection_button_row_rect.y, selection_button_row_rect.y + selection_button_row_rect.height);

                            onClicked: {
                                selection_button_row.setSelection(0);
                            }
                        }

                        BasicButton
                        {
                            id: invert_selection_button
                            width: selection_button_row.button_width
                            height: parent.height
                            text: qsTr("Invert Selection")
                            hover_color: textColor
                            onNextFocus: function next_focus(dir) {
                                if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                                else if(dir === Enums.FocusDir.Up) combo_selection_address.setFocus(dir);
                                else if(dir === Enums.FocusDir.Left) unselect_all_button.setFocus(dir);
                                else organization_button_selection.setFocus(dir);
                            }

                            onFocusSet: search_parameter_scroll_view.scrollTo(selection_button_row_rect.y, selection_button_row_rect.y + selection_button_row_rect.height);

                            onClicked: {
                                selection_button_row.setSelection(-1);
                            }
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
                    onNextFocus: function next_focus(dir) {
                        organization_button_selection.element_id_with_focus = -2;
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up) select_all_button.setFocus(dir);
                        else if(dir === Enums.FocusDir.Left) invert_selection_button.setFocus(dir);
                        else person_button_selection.setFocus(dir);
                    }

                    onFocusSet: search_parameter_scroll_view.scrollTo(y, y + height);

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
                    onNextFocus: function next_focus(dir) {
                        person_button_selection.element_id_with_focus = -2;
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) organization_button_selection.setFocus(dir);
                        else address_button_selection.setFocus(dir);
                    }

                    onFocusSet: search_parameter_scroll_view.scrollTo(y, y + height);

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
                    onNextFocus: function next_focus(dir) {
                        address_button_selection.element_id_with_focus = -2;
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) person_button_selection.setFocus(dir);
                        else reload_search_button.setFocus(dir);
                    }

                    onFocusSet: search_parameter_scroll_view.scrollTo(y, y + height);

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

                Row
                {
                    id: search_button_row
                    width: parent.width
                    height: search_parameter_column.module_height * 1
                    spacing: 8
                    property int column_count: 2
                    property var button_width: (width - ((column_count - 1) * spacing)) / column_count

                    BasicButton
                    {
                        id: reload_search_button
                        width: search_button_row.button_width
                        height: parent.height
                        text: qsTr("Reload Results")
                        hover_color: textColor
                        onNextFocus: function next_focus(dir) {
                            if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                            else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) address_button_selection.setFocus(dir);
                            else if(dir === Enums.FocusDir.Right) reset_search_button.setFocus(dir);
                            else tab_row.setFocus(dir);
                        }

                        onFocusSet: search_parameter_scroll_view.scrollTo(search_button_row.y, search_button_row.y + search_button_row.height);

                        onClicked: {
                            database.clear_cache();
                            updateSearch();
                        }
                    }

                    BasicButton
                    {
                        id: reset_search_button
                        width: search_button_row.button_width
                        height: parent.height
                        text: qsTr("Reset Search")
                        highlight_color: backgroundColorError
                        onNextFocus: function next_focus(dir) {
                            if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                            else if(dir === Enums.FocusDir.Up) address_button_selection.setFocus(dir);
                            else if(dir === Enums.FocusDir.Left) reload_search_button.setFocus(dir);
                            else tab_row.setFocus(dir);
                        }

                        onFocusSet: search_parameter_scroll_view.scrollTo(search_button_row.y, search_button_row.y + search_button_row.height);

                        onClicked: {
                            resetSearch();
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
            color: {
                if(separator_mouse_area.drag.active) return highlightColor;
                else if(separator_mouse_area.containsMouse) return highlightColor;
                else return backgroundColor3;
            }
            Behavior on color {
                enabled: !separator_mouse_area.drag.active

                ColorAnimation
                {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
            anchors.horizontalCenter: parent.horizontalCenter

            MouseArea
            {
                id: separator_mouse_area
                visible: true
                enabled: true
                anchors.fill: parent
                anchors.margins: -2
                drag.target: separator
                drag.axis: Drag.YAxis
                hoverEnabled: true
                drag.minimumY: relative_to_absolute_y(main_column.min_distribution)
                drag.maximumY: relative_to_absolute_y(main_column.max_distribution)
                cursorShape: Qt.SplitVCursor

                function relative_to_absolute_y(y_val) {
                    const height = main_column.height;
                    return height * y_val;
                }

                function absolute_to_relative_y(y_val) {
                    const height = main_column.height;
                    return y_val / height;
                }

                onDoubleClicked: {
                    main_column.distribution = 0.5;
                }

                onPositionChanged: {
                    if(drag.active) {
                        main_column.distribution = absolute_to_relative_y(separator.y);
                    }
                }
            }
        }

        Column
        {
            id: table_column
            width: parent.width
            height: main_column.table_column_height
            spacing: 4

            property int row_count: 2
            property var distribution: 0.9
            property var tab_row_height: (main_column.table_column_default_height - ((row_count - 1) * spacing)) * (1 - distribution)
            //property var tab_row_default_height: (main_column.table_column_default_height - ((row_count - 1) * spacing)) * (1 - distribution)
            property var table_height: (height - ((row_count - 1) * spacing)) - tab_row_height
            //property var table_default_height: (main_column.table_column_default_height - ((row_count - 1) * spacing)) * distribution

            Rectangle
            {
                id: tab_row_rect
                width: parent.width - 8
                height: table_column.tab_row_height
                anchors.horizontalCenter: parent.horizontalCenter
                color: backgroundColor2
                radius: 4

                Row
                {
                    id: tab_row
                    spacing: 8
                    anchors.fill: parent
                    property int column_count: 4
                    property var module_width: (width - ((column_count - 1) * spacing)) / column_count

                    function setFocus(dir) {
                        if(search_result_table_stack_layout.currentIndex === 0) organization_table_search_results_button.setFocus(dir);
                        else if(search_result_table_stack_layout.currentIndex === 1) person_table_search_results_button.setFocus(dir);
                        else if(search_result_table_stack_layout.currentIndex === 2) address_table_search_results_button.setFocus(dir);
                    }

                    Text
                    {
                        text: qsTr("Results:")
                        width: tab_row.module_width
                        height: parent.height
                        font.pointSize: fontSize_default
                        font.family: fontFamily_default
                        color: textColor1
                        horizontalAlignment: Text.AlignHCenter
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
                        onNextFocus: function next_focus(dir) {
                            if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                            else if(dir === Enums.FocusDir.Up) reload_search_button.setFocus(dir);
                            else if(dir === Enums.FocusDir.Left) reset_search_button.setFocus(dir);
                            else if(dir === Enums.FocusDir.Right) person_table_search_results_button.setFocus(dir);
                            else search_result_table_stack_layout.setFocus(dir);
                        }

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
                        onNextFocus: function next_focus(dir) {
                            if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                            else if(dir === Enums.FocusDir.Up) reload_search_button.setFocus(dir);
                            else if(dir === Enums.FocusDir.Left) organization_table_search_results_button.setFocus(dir);
                            else if(dir === Enums.FocusDir.Right) address_table_search_results_button.setFocus(dir);
                            else search_result_table_stack_layout.setFocus(dir);
                        }

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
                        onNextFocus: function next_focus(dir) {
                            if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                            else if(dir === Enums.FocusDir.Up) reload_search_button.setFocus(dir);
                            else if(dir === Enums.FocusDir.Left) person_table_search_results_button.setFocus(dir);
                            else search_result_table_stack_layout.setFocus(dir);
                        }

                        onClicked:
                        {
                            search_result_table_stack_layout.currentIndex = stack_layout_index;
                        }
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

                function setFocus(dir) {
                    if(currentIndex === 0) organization_result_table.setFocus(dir);
                    else if(currentIndex === 1) person_result_table.setFocus(dir);
                    else if(currentIndex === 2) address_result_table.setFocus(dir);
                }
            
                SearchResultTable
                {
                    id: organization_result_table
                    height: parent.height
                    width: parent.width

                    table_name: "organization"
                    search_res: organization_search_res
                    table_cell_rect_height_factor: Math.min(Math.max(0.0, 0.16 * (211 / height)), 1.0)
                    table_view_main_height_factor: 0.87 + Math.min(Math.max(-0.3, (height / 1918) - 0.12), 0.05)

                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) tab_row.setFocus(dir);
                        else tab_main.nextFocus(dir);
                    }

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
                    height: parent.height
                    width: parent.width

                    table_name: "person"
                    search_res: person_search_res
                    table_cell_rect_height_factor: Math.min(Math.max(0.0, 0.16 * (211 / height)), 1.0)
                    table_view_main_height_factor: 0.87 + Math.min(Math.max(-0.3, (height / 1918) - 0.12), 0.05)

                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) tab_row.setFocus(dir);
                        else tab_main.nextFocus(dir);
                    }

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
                    height: parent.height
                    width: parent.width

                    table_name: "address"
                    search_res: address_search_res
                    table_cell_rect_height_factor: Math.min(Math.max(0.0, 0.16 * (211 / height)), 1.0)
                    table_view_main_height_factor: 0.87 + Math.min(Math.max(-0.3, (height / 1918) - 0.12), 0.05)

                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) tab_main.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Left) tab_row.setFocus(dir);
                        else tab_main.nextFocus(dir);
                    }

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