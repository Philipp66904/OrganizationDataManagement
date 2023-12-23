import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"

import tablemodule 1.0

TemplateEditDialog
{
    id: organization_dialog
    required property int pk_id
    identifier: pk_id
    parent_identifier: parent_id
    entry_name: qsTr("New Entry")
    window_title: qsTr("Add / Edit Organization")
    title_name: qsTr("Organization")
    table_name: qsTr("organization")
    property var parent_id: undefined
    property string qml_file_name: "OrganizationEditDialog.qml"
    property_height: height * 0.7

    onClosing: max_derivate_windows++;

    // current property values
    property string property_name: ""
    property string property_note: ""

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        max_derivate_windows--;

        let entry_name_tmp = "New Entry";
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", organization_dialog.table_name)
        organization_dialog.entry_name = entry_name_tmp;

        // init properties
        organization_dialog.property_name = (identifier >= 0) ? database.getName_byPk(identifier, "id", organization_dialog.table_name) : ""
        organization_dialog.property_note = (identifier >= 0) ? database.getNote_byPk(identifier, "id", organization_dialog.table_name) : ""

        init();
    }

    onSave_button_clicked: {
        console.log("save");

        if(identifier >= 0) {
            // Update existing entry
            error_message = database.setName_Note_byPk(property_name.trim(), property_note, identifier, "id", organization_dialog.table_name);
            if(error_message !== "") return;
        }
        else {
            // TODO create new entry
        }
    }

    onDelete_button_clicked: {
        console.log("delete");
    }

    onDerivate_add_button_clicked: function derivate_add_button_clicked() {
        create_derivate_window(-1, qml_file_name);
    }

    onDerivate_edit_button_clicked: function derivate_edit_button_clicked(pk) {
        create_derivate_window(pk, qml_file_name);
    }

    onDerivate_duplicate_button_clicked: function derivate_duplicate_button_clicked(pk) {
        console.log("duplicate derivate:", pk)
        // TODO implement
    }

    onDerivate_delete_button_clicked: function derivate_delete_button_clicked(pk) {
        console.log("delete derivate:", pk)
        // TODO implement
    }

    Component
    {
        id: property_component

        Column
        {
            spacing: 8
            property int row_count: 8

            PropertyLineEdit
            {
                id: property_line_edit_name
                width: parent.width
                height: (parent.height - (row_count * spacing)) / row_count
                description: "Name"
                value: property_name
                original_value: ""
                derivate_mode: false

                Connections {
                    target: organization_dialog
                    function onInitProperties() {
                        property_line_edit_name.original_value = property_name;
                    }
                }

                onNew_value: function new_value(value, derivate_flag) {
                    property_name = value;

                    if(identifier < 0 && value.trim() === "") organization_dialog.entry_name = "New Entry";
                    else organization_dialog.entry_name = value.trim();
                }
            }

            Text
            {
                id: derivate_description_text
                width: parent.width
                height: ((parent.height - (row_count * spacing)) / row_count) * 0.5
                text: qsTr("Connections:")
                font.pointSize: textSize
                color: backgroundColor3
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            Table
            {
                id: connections_table
                height: ((parent.height - (row_count * spacing)) / row_count) * 4
                width: parent.width
                parent_id: undefined
                anchors.horizontalCenter: parent.horizontalCenter
                table_view_main_height_factor: 0.8
                table_cell_rect_height_factor: 0.25
                pk_id: organization_dialog.identifier
                show_duplicate_button: false

                TableModel
                {
                    id: table_model
                }

                function load_data() {
                    const res = database.getConnections(organization_dialog.identifier);
                    const column_names = res.shift();
                    console.log("load data");

                    table_model.loadData(organization_dialog.table_name, column_names, res);
                }

                Connections {
                    target: organization_dialog
                    function onInitProperties() {
                        connections_table.load_data();
                    }
                }

                OrganizationConnectionDialog
                {
                    id: organization_connection_dialog
                    window_title: qsTr("Add / Edit Connection")
                    identifier: -1
                    title_name: qsTr("Connection")
                }

                onAdd_button_clicked: function add_button_clicked() {
                    organization_connection_dialog.show();
                    organization_connection_dialog.init(-1, identifier);
                }

                onEdit_button_clicked: function edit_button_clicked(pk) {
                    organization_connection_dialog.show();
                    organization_connection_dialog.init(pk, identifier);
                }

                onDelete_button_clicked: function delete_button_clicked(pk) {
                    error_message = database.deleteConnection(pk);
                }
            }

            PropertyParagraphEdit
            {
                id: property_paragraph_edit_note
                width: parent.width
                height: ((parent.height - (row_count * spacing)) / row_count) * 3
                description: "Note"
                value: property_note
                original_value: ""
                derivate_mode: false

                Connections {
                    target: organization_dialog
                    function onInitProperties() {
                        property_paragraph_edit_note.original_value = property_note;
                    }
                }

                onNew_value: function new_value(value, derivate_flag) {
                    property_note = value;
                }
            }
        }
    }
}