import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../components"
import "../types"

import tablemodule 1.0

ApplicationWindow
{
    id: edit_dialog_window
    title: {
        let res = "";
        if(unsaved_changes) res += "*";
        res += window_title;
        res += " - " + entry_name;
        return res;
    }
    color: backgroundColor1
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 450
    width: rootWindow.width * 0.8
    height: rootWindow.height * 0.8

    property bool save_button_enabled: true
    property bool close_okay: false
    property bool unsaved_changes: false

    required property string window_title
    required property var identifier
    required property var parent_identifier
    required property string title_name
    required property string entry_name
    required property string table_name

    required property var property_height

    signal derivative_add_button_clicked()
    signal derivative_edit_button_clicked(selected_primary_key: int)
    signal derivative_duplicate_button_clicked(selected_primary_key: int)
    signal derivative_delete_button_clicked(selected_primary_key: int)

    signal save_button_clicked()
    signal delete_button_clicked()

    signal initProperties()

    function init_dialog() {}  // implement this function

    function init() {  // call this function in your init_dialog override
        close_okay = false;
        unsaved_changes = false;
        derivative_table.load_data();
        edit_dialog_window.initProperties();
        save_button.setFocus(Enums.FocusDir.Down);
        main_scroll_view.ScrollBar.vertical.position = 0;  // Scrolling to the top

        edit_dialog_window.width = rootWindow.width * 0.8;
        edit_dialog_window.height = rootWindow.height * 0.8;

        edit_dialog_window.x = ((rootWindow.width - edit_dialog_window.width) / 2) + rootWindow.x;
        edit_dialog_window.y = ((rootWindow.height - edit_dialog_window.height) / 2) + rootWindow.y;
    }

    function create_derivative_window(pk, qml_file_name) {
        var component = Qt.createComponent(qml_file_name);
        var new_dialog_window = component.createObject(edit_dialog_window, { pk_id: pk, parent_id: identifier });

        if (new_dialog_window == null) {
            setStatusMessage(qsTr("Error in creating a new window"), Enums.StatusMsgLvl.Err);
        }
        else {
            new_dialog_window.show();
            new_dialog_window.init_dialog();
        }
    }

    // Shortcuts
    CustomShortcuts
    {
        shortcutSaveEnabled: true
        onShortcutSave: save_button.clicked();
        shortcutCloseEnabled: true
        onShortcutClose: abort_button.clicked();
        shortcutDeleteEnabled: true
        onShortcutDelete: delete_button.clicked();
    }

    // Closing handler
    UnsavedChangesCloseDialog
    {
        id: abort_dialog
        function callback_function() { edit_dialog_window.close_okay = true; edit_dialog_window.close(); }
    }
    onClosing: (close) => {
        if(!unsaved_changes) return;

        close.accepted = false;
        if(!close_okay) {
            abort_dialog.init();
            abort_dialog.show();
        }

        if(close_okay) close.accepted = true;
    }

    Column
    {
        id: main_column
        anchors.fill: parent
        spacing: 4
        property int row_count: 6

        property int title_rect_height: (height - (row_count * spacing)) * 0.07
        property int scrollview_height: (height - (row_count * spacing)) * 0.84
        property int button_row_height: (height - (row_count * spacing)) * 0.06
        property int date_row_height: (height - (row_count * spacing)) - title_rect_height - scrollview_height - button_row_height - 2

        // ScrollView content heights
        property int derivative_description_text_height: (height - (row_count * spacing)) * 0.03
        property int table_height: (height - (row_count * spacing)) * 0.3

        Component
        {
            id: separator_component

            Rectangle
            {
                width: main_column.width
                height: 1
                color: backgroundColor3
            }
        }

        Rectangle
        {
            id: title_rect
            height: main_column.title_rect_height
            width: parent.width
            color: backgroundColor2

            Row
            {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8

                Text
                {
                    id: title_text
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height
                    text: edit_dialog_window.title_name
                    font.pointSize: fontSize_big
                    font.family: fontFamily_big
                    color: textColor
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font.bold: true
                }

                Text
                {
                    id: entry_name_text
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height
                    text: edit_dialog_window.entry_name
                    font.pointSize: fontSize_big
                    font.family: fontFamily_big
                    color: textColor1
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        ScrollView
        {
            id: main_scroll_view
            width: parent.width
            height: main_column.scrollview_height
            anchors.horizontalCenter: parent.horizontalCenter
            contentHeight: scrollview_column.height
            contentWidth: width
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
                id: scrollview_column
                width: parent.width
                height: {
                    let h = derivative_description_text.height;
                    h += derivative_table.height;
                    h += property_settings.height;
                    h += 1 * 1;  // separator_component.height
                    h += spacing * row_count;
                    return h;
                }
                spacing: main_column.spacing
                property int row_count: 4

                Item
                {
                    id: property_settings
                    width: parent.width - 8
                    height: edit_dialog_window.property_height * main_column.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    // implement the Component with the id property_component
                    Loader
                    {
                        id: property_component_loader
                        sourceComponent: property_component
                        anchors.fill: parent
                    }

                    Connections
                    {
                        target: property_component_loader.item
                        function onNextFocus(dir) {
                            if(dir === Enums.FocusDir.Save) save_button.setFocus(Enums.FocusDir.Right);
                            else if(dir === Enums.FocusDir.Close) abort_button.setFocus(Enums.FocusDir.Left);
                            else if(dir === Enums.FocusDir.Right || dir === Enums.FocusDir.Down) derivative_table.setFocus(dir);
                            else button_row_rect.setFocus(dir);
                        }

                        function onScrollTo(y_coord_top, y_coord_bot) {
                            main_scroll_view.scrollTo(y_coord_top, y_coord_bot);
                        }
                    }
                }

                Loader { sourceComponent: separator_component; }

                Text
                {
                    id: derivative_description_text
                    width: parent.width - 8
                    height: main_column.derivative_description_text_height
                    text: qsTr("Derivatives:")
                    font.pointSize: fontSize_default
                    font.family: fontFamily_default
                    color: textColor1
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Table
                {
                    id: derivative_table
                    height: main_column.table_height
                    width: parent.width - 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    table_name: edit_dialog_window.table_name
                    table_view_main_height_factor: 0.8
                    table_cell_rect_height_factor: 0.25
                    pk_id: identifier
                    parent_id: parent_identifier
                    onNextFocus: function next_focus(dir) {
                        if(property_component_loader.item === null) return;

                        if(dir === Enums.FocusDir.Save) save_button.setFocus(Enums.FocusDir.Right);
                        else if(dir === Enums.FocusDir.Close) abort_button.setFocus(Enums.FocusDir.Left);
                        else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_component_loader.item.setFocus(dir);
                        else button_row_rect.setFocus(dir);
                    }

                    onFocusSet: main_scroll_view.scrollTo(y, y + height);

                    TableModel
                    {
                        id: table_model
                    }

                    function load_data() {
                        const res = database.getDataDerivatives(edit_dialog_window.identifier, "parent_id", edit_dialog_window.table_name);
                        const column_names = database.translateColumnNames(res.shift());

                        table_model.loadData(edit_dialog_window.table_name, column_names, res);
                    }

                    function load_row_data(index) {
                        const row_data = database.getDataRowDerivative(index, "id", edit_dialog_window.identifier, "parent_id", edit_dialog_window.table_name);
                        if(row_data.length > 0) {
                            table_model.changeRowData(index, "id", row_data);
                        }
                    }
                    function load_add_row_data(index) {
                        const row_data = database.getDataRowDerivative(index, "id", edit_dialog_window.identifier, "parent_id", edit_dialog_window.table_name);
                        if(row_data.length > 0) {
                            table_model.addRowData(-1, row_data);
                        }
                    }

                    onAdd_button_clicked: function add_button_clicked() {
                        edit_dialog_window.derivative_add_button_clicked();
                    }

                    onEdit_button_clicked: function edit_button_clicked(pk) {
                        edit_dialog_window.derivative_edit_button_clicked(pk);
                    }

                    onDuplicate_button_clicked: function duplicate_button_clicked(pk) {
                        edit_dialog_window.derivative_duplicate_button_clicked(pk);
                    }

                    onDelete_button_clicked: function delete_button_clicked(pk) {
                        const msg = setStatusMessage(database.deleteEntry(pk, "id", edit_dialog_window.table_name), Enums.StatusMsgLvl.Err);
                        if(msg !== "") return;

                        edit_dialog_window.derivative_delete_button_clicked(pk);
                    }
                }
            }
        }

        Loader { sourceComponent: separator_component; }

        Rectangle
        {
            id: button_row_rect
            width: parent.width - 8
            height: main_column.button_row_height
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            radius: 8

            function setFocus(dir) {
                if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Save) save_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Right) save_button.setFocus(Enums.FocusDir.Right);
                else if(dir === Enums.FocusDir.Left) abort_button.setFocus(dir);
                else save_button.setFocus(Enums.FocusDir.Right);
            }

            Row
            {
                id: button_row
                anchors.fill: parent
                
                spacing: 8
                property int button_count: 3

                BasicButton
                {
                    id: save_button
                    width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                    height: parent.height
                    hover_color: highlight_color
                    text: qsTr("Save")
                    button_enabled: save_button_enabled
                    focus: true
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close) abort_button.setFocus(Enums.FocusDir.Left);
                        else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) derivative_table.setFocus(dir);
                        else if(dir === Enums.FocusDir.Down && property_component_loader.item !== null) property_component_loader.item.setFocus(dir);
                        else delete_button.setFocus(dir);
                    }

                    onClicked: {
                        edit_dialog_window.save_button_clicked();

                        close_okay = true;
                        edit_dialog_window.close();
                            
                    }
                }

                BasicButton
                {
                    id: delete_button
                    width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                    height: parent.height
                    highlight_color: backgroundColorError
                    text: qsTr("Delete")
                    button_enabled: (edit_dialog_window.identifier !== -1) ? true : false
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Save) save_button.setFocus(Enums.FocusDir.Right);
                        else if(dir === Enums.FocusDir.Close) abort_button.setFocus(Enums.FocusDir.Left);
                        else if(dir === Enums.FocusDir.Up) derivative_table.setFocus(dir);
                        else if(dir === Enums.FocusDir.Left) save_button.setFocus(dir);
                        else if(dir === Enums.FocusDir.Down && property_component_loader.item !== null) property_component_loader.item.setFocus(dir);
                        else abort_button.setFocus(dir);
                    }

                    DeleteDialog
                    {
                        id: delete_dialog
                        function callback_function() {
                            const msg = setStatusMessage(database.deleteEntry(edit_dialog_window.identifier, "id", edit_dialog_window.table_name), Enums.StatusMsgLvl.Err);
                            if(msg !== "") return;

                            edit_dialog_window.delete_button_clicked();
                            close_okay = true;
                            edit_dialog_window.close();
                        }
                    }

                    onClicked: {
                        delete_dialog.init();
                        delete_dialog.setSubText(edit_dialog_window.identifier, "id", edit_dialog_window.table_name);
                        delete_dialog.show();
                    }
                }

                BasicButton
                {
                    id: abort_button
                    width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                    height: parent.height
                    hover_color: textColor
                    text: qsTr("Abort")
                    button_enabled: true
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Save) save_button.setFocus(Enums.FocusDir.Right);
                        else if(dir === Enums.FocusDir.Close) clicked();
                        else if(dir === Enums.FocusDir.Up) derivative_table.setFocus(dir);
                        else if(dir === Enums.FocusDir.Left) delete_button.setFocus(dir);
                        else if(property_component_loader.item !== null) property_component_loader.item.setFocus(dir);
                    }

                    onClicked: {
                        edit_dialog_window.close();
                    }
                }
            }
        }

        Loader { sourceComponent: separator_component; }

        Rectangle
        {
            id: date_rect
            width: parent.width - 8
            height: main_column.date_row_height
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"
            
            MouseArea
            {
                id: date_rect_mouse_area
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
            }

            Row
            {
                id: date_row
                anchors.fill: parent
                spacing: 4
                property int column_count: 3
                property string modified_date: ""
                property string created_date: ""
                property color text_color: (date_rect_mouse_area.containsMouse) ? textColor : textColor1
                Behavior on text_color {
                    enabled: true

                    ColorAnimation
                    {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                function load_dates() {
                    const dates = database.getMetadata(identifier, "id", table_name);
                    date_row.modified_date = dates[0];
                    date_row.created_date = dates[1];

                    if(dates[0] === "" && dates[1] === "") {
                        const new_entry_description_text = qsTr("New Entry");
                        date_row.modified_date = new_entry_description_text;
                        date_row.created_date = new_entry_description_text;
                    }
                }

                Connections {
                    target: edit_dialog_window
                    function onInitProperties() {
                        date_row.load_dates();
                    }
                }

                Rectangle
                {
                    id: date_modified_rect
                    height: parent.height
                    width: ((parent.width - ((parent.column_count - 1) * parent.spacing)) / 2) - separator_rect.width
                    color: "transparent"

                    Text
                    {
                        id: date_modified_text
                        text: qsTr("Modified: ") + date_row.modified_date
                        anchors.fill: parent
                        anchors.margins: 4
                        font.pointSize: fontSize_small
                        font.family: fontFamily_small
                        color: date_row.text_color
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

                Rectangle
                {
                    id: separator_rect
                    height: parent.height
                    width: 1
                    color: backgroundColor3
                }

                Rectangle
                {
                    id: date_created_rect
                    height: parent.height
                    width: (parent.width - ((parent.column_count - 1) * parent.spacing)) / 2
                    color: "transparent"

                    Text
                    {
                        id: date_created_text
                        text: qsTr("Created: ") + date_row.created_date
                        anchors.fill: parent
                        anchors.margins: 4
                        font.pointSize: fontSize_small
                        font.family: fontFamily_small
                        color: date_row.text_color
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}