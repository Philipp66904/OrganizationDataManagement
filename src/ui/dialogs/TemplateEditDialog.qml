import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../components"

import tablemodule 1.0

ApplicationWindow
{
    id: edit_dialog_window
    title: window_title + " - " + entry_name
    color: backgroundColor
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 90
    width: rootWindow.width * 0.8
    height: rootWindow.height * 0.8

    required property string window_title
    required property var identifier
    required property var parent_identifier
    required property string title_name
    required property string entry_name
    required property string table_name

    required property var property_height

    signal derivate_add_button_clicked()
    signal derivate_edit_button_clicked(selected_primary_key: int)
    signal derivate_duplicate_button_clicked(selected_primary_key: int)
    signal derivate_delete_button_clicked(selected_primary_key: int)

    signal save_button_clicked()
    signal delete_button_clicked()

    signal initProperties()

    function init_dialog() {}  // implement this function

    function init() {  // call this function in your init_dialog override
        derivate_table.load_data();
        edit_dialog_window.initProperties();
    }

    function create_derivate_window(pk, qml_file_name) {
        if(max_derivate_windows <= 0) {
            error_message = qsTr("Max amount of derivate windows reached");
            return;
        }

        var component = Qt.createComponent(qml_file_name);
        var new_dialog_window = component.createObject(organization_dialog, { pk_id: pk, parent_id: identifier });

        if (new_dialog_window == null) {
            error_message = qsTr("Error in creating a new window");
        }
        else {
            new_dialog_window.show();
            new_dialog_window.init_dialog();
        }
    }

    Column
    {
        id: main_column
        anchors.fill: parent
        spacing: 4
        property int row_count: 6

        property int title_rect_height: (height - (row_count * spacing)) * 0.07
        property int scrollview_height: (height - (row_count * spacing)) * 0.82
        property int button_row_height: (height - (row_count * spacing)) * 0.06
        property int date_row_height: (height - (row_count * spacing)) - title_rect_height - scrollview_height - button_row_height - 2

        // ScrollView content heights
        property int derivate_description_text_height: (height - (row_count * spacing)) * 0.03
        property int table_height: (height - (row_count * spacing)) * 0.3

        Component
        {
            id: separator_component

            Rectangle
            {
                width: main_column.width
                height: 1
                color: backgroundColor1
            }
        }

        Rectangle
        {
            id: title_rect
            height: main_column.title_rect_height
            width: parent.width
            color: backgroundColor1

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
                    font.pointSize: textSizeBig
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
                    font.pointSize: textSizeBig
                    color: backgroundColor3
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        ScrollView
        {
            width: parent.width
            height: main_column.scrollview_height
            anchors.horizontalCenter: parent.horizontalCenter
            contentHeight: scrollview_column.height
            contentWidth: width
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff  // actually not needed because of contentWidth: width, just to be safe

            Column
            {
                id: scrollview_column
                width: parent.width
                height: {
                    let h = derivate_description_text.height;
                    h += derivate_table.height;
                    h += property_settings.height;
                    h += 1 * 1;  // separator_component.height
                    h += spacing * row_count;
                    return h;
                }
                spacing: main_column.spacing
                property int row_count: 4

                Text
                {
                    id: derivate_description_text
                    width: parent.width - 8
                    height: main_column.derivate_description_text_height
                    text: qsTr("Derivates:")
                    font.pointSize: textSize
                    color: backgroundColor3
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                Table
                {
                    id: derivate_table
                    height: main_column.table_height
                    width: parent.width - 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    table_view_main_height_factor: 0.8
                    table_cell_rect_height_factor: 0.25
                    pk_id: identifier
                    parent_id: parent_identifier

                    TableModel
                    {
                        id: table_model
                    }

                    function load_data() {
                        const res = database.getDataDerivates(edit_dialog_window.identifier, "parent_id", edit_dialog_window.table_name);
                        const column_names = res.shift();

                        table_model.loadData(edit_dialog_window.table_name, column_names, res);
                    }

                    onAdd_button_clicked: function add_button_clicked() {
                        edit_dialog_window.derivate_add_button_clicked();
                    }

                    onEdit_button_clicked: function edit_button_clicked(pk) {
                        edit_dialog_window.derivate_edit_button_clicked(pk);
                    }

                    onDuplicate_button_clicked: function duplicate_button_clicked(pk) {
                        error_message = database.duplicateEntry(pk, "id", edit_dialog_window.table_name);
                        if(error_message !== "") return;

                        edit_dialog_window.derivate_duplicate_button_clicked(pk);
                    }

                    onDelete_button_clicked: function delete_button_clicked(pk) {
                        error_message = database.deleteEntry(pk, "id", edit_dialog_window.table_name);
                        if(error_message !== "") return;

                        edit_dialog_window.derivate_delete_button_clicked(pk);
                    }
                }

                Loader { sourceComponent: separator_component; }

                Item
                {
                    id: property_settings
                    width: parent.width - 8
                    height: edit_dialog_window.property_height * main_column.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    // implement the Component with the id property_component
                    Loader { sourceComponent: property_component; anchors.fill: parent }
                }
            }
        }

        Loader { sourceComponent: separator_component; }

        Row
        {
            id: button_row
            width: parent.width - 8
            height: main_column.button_row_height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            property int button_count: 3

            BasicButton
            {
                id: save_button
                width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                height: parent.height
                hover_color: highlight_color
                text: qsTr("Save")
                button_enabled: true

                onClicked:
                {
                    edit_dialog_window.save_button_clicked();
                    edit_dialog_window.close();
                }
            }

            BasicButton
            {
                id: delete_button
                width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                height: parent.height
                highlight_color: "#ff0000"
                text: qsTr("Delete")
                button_enabled: (edit_dialog_window.identifier !== -1) ? true : false

                DeleteDialog
                {
                    id: delete_dialog
                    function callback_function() {
                        error_message = database.deleteEntry(edit_dialog_window.identifier, "id", edit_dialog_window.table_name);
                        if(error_message !== "") return;

                        edit_dialog_window.delete_button_clicked();
                        edit_dialog_window.close();
                    }
                }

                onClicked:
                {
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

                FileCloseDialog 
                {
                    id: abort_dialog
                    function callback_function() { edit_dialog_window.close(); }
                }

                onClicked:
                {
                    abort_dialog.show();
                }
            }
        }

        Loader { sourceComponent: separator_component; }

        Row
        {
            id: date_row
            width: parent.width - 8
            height: main_column.date_row_height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            property int column_count: 3
            property string modified_date: ""
            property string created_date: ""

            function load_dates() {
                const dates = database.getMetadata(identifier, "id", table_name);
                date_row.modified_date = dates[0];
                date_row.created_date = dates[1];
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
                    font.pointSize: textSizeSmall
                    color: backgroundColor3
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
                color: backgroundColor1
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
                    font.pointSize: textSizeSmall
                    color: backgroundColor3
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }
}