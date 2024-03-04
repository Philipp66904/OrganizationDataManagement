import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"
import "../types"

import tablemodule 1.0

TemplateEditDialog
{
    id: organization_dialog
    required property int pk_id
    identifier: pk_id
    parent_identifier: parent_id
    entry_name: qsTr("New Entry")
    window_title: (pk_id >= 0) ? qsTr("Edit Organization") : qsTr("Add Organization")
    title_name: qsTr("Organization")
    table_name: "organization"
    property var parent_id: undefined
    property string qml_file_name: "OrganizationEditDialog.qml"
    property_height: 0.8 * (480.0 / height)

    // current property values
    property string property_name: ""
    property string property_note: ""
    property var property_website: ""
    property bool property_website_derivative_flag: false
    property var property_website_derivative: undefined

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        let entry_name_tmp = qsTr("New Entry");
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", organization_dialog.table_name);
        organization_dialog.entry_name = entry_name_tmp.trim();

        // init properties
        organization_dialog.property_name = (identifier >= 0) ? database.getName_byPk(identifier, "id", organization_dialog.table_name) : "";
        organization_dialog.property_note = (identifier >= 0) ? database.getNote_byPk(identifier, "id", organization_dialog.table_name) : "";
        
        if(identifier >= 0) {
            const property_website_tmp = database.getData(identifier, "id", "website", organization_dialog.table_name);
            organization_dialog.property_website = property_website_tmp[0];
            organization_dialog.property_website_derivative_flag = property_website_tmp[1];
            organization_dialog.property_website_derivative = database.getDataDerivative(identifier, "id", "website", organization_dialog.table_name)[0];
        }
        else if(parent_identifier !== undefined && parent_identifier >= 0) {
            const property_website_tmp = database.getData(parent_identifier, "id", "website", organization_dialog.table_name);
            organization_dialog.property_website = property_website_tmp[0];
            organization_dialog.property_website_derivative_flag = true;
            organization_dialog.property_website_derivative = property_website_tmp[0];
        }
        else {
            organization_dialog.property_website = undefined;
            organization_dialog.property_website_derivative_flag = false;
            organization_dialog.property_website_derivative = undefined;
        }

        init();
    }

    onSave_button_clicked: {
        if(identifier >= 0) {
            // Update existing entry
            let msg = setStatusMessage(database.setName_Note_byPk(property_name, property_note, identifier, "id", organization_dialog.table_name), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_website = undefined;
            if(!property_website_derivative_flag) new_website = property_website;
            msg = setStatusMessage(database.setValue_Str("website", identifier, "id", organization_dialog.table_name, new_website), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;
        }
        else {
            // Create new entry
            let new_website = undefined;
            if(!property_website_derivative_flag) new_website = property_website;

            let new_parent_id = -1;
            if(parent_identifier !== undefined) new_parent_id = parent_identifier;
            
            const msg = setStatusMessage(database.createOrganization(property_name, property_note, new_parent_id, new_website), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;
        }

        unsaved_changes = false;
    }

    onDerivative_add_button_clicked: function derivative_add_button_clicked() {
        create_derivative_window(-1, qml_file_name);
    }

    onDerivative_edit_button_clicked: function derivative_edit_button_clicked(pk) {
        create_derivative_window(pk, qml_file_name);
    }

    onDerivative_duplicate_button_clicked: function derivative_duplicate_button_clicked(pk) {
        const msg = setStatusMessage(database.duplicateEntry(pk, "id", organization_dialog.table_name), Enums.StatusMsgLvl.Err);
        if(msg !== "") return;
    }

    Component
    {
        id: property_component

        Column
        {
            spacing: 8
            property var row_count: 5
            property var row_height_count: 9.5 * (height / 384.0)

            function setFocus(dir) {
                if(dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Right) property_line_edit_name.setFocus(dir);
                else property_paragraph_edit_note.setFocus(dir);
            }

            signal nextFocus(dir: int)

            PropertyLineEdit
            {
                id: property_line_edit_name
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Name")
                value: property_name
                derivative_value: ""
                derivative_mode: false
                required: true
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) parent.nextFocus(dir);
                    else connections_table.setFocus(dir);
                }

                Connections {
                    target: organization_dialog
                    function onInitProperties() {
                        property_line_edit_name.derivative_value = property_name;
                        organization_dialog.save_button_enabled = (property_name.trim().length > 0);
                    }
                }

                onNew_value: function new_value(value, derivative_flag) {
                    unsaved_changes = true;
                    property_name = value;

                    if(identifier < 0 && value.trim() === "") organization_dialog.entry_name = qsTr("New Entry");
                    else organization_dialog.entry_name = value.trim();

                    organization_dialog.save_button_enabled = (value.trim().length > 0);
                }
            }

            Text
            {
                id: derivative_description_text
                width: parent.width
                height: ((parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count) * 0.5
                text: qsTr("Connections:")
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
                id: connections_table
                height: ((parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count) * 4
                width: parent.width
                parent_id: undefined
                anchors.horizontalCenter: parent.horizontalCenter
                table_name: "connection"
                table_view_main_height_factor: 0.8
                table_cell_rect_height_factor: 0.25
                pk_id: organization_dialog.identifier
                show_duplicate_button: false
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_name.setFocus(dir);
                    else property_line_edit_website.setFocus(dir);
                }

                TableModel
                {
                    id: table_model
                }

                function load_data() {
                    const res = database.getConnections(organization_dialog.identifier);
                    const column_names = res.shift();

                    table_model.loadData(organization_dialog.table_name, column_names, res);
                }

                function load_row_data(index) {
                    const row_data = database.getRowConnection(index, organization_dialog.identifier);
                    if(row_data.length > 0) {
                        table_model.changeRowData(index, "id", row_data);
                    }
                }
                function load_add_row_data(index) {
                    const row_data = database.getRowConnection(index, organization_dialog.identifier);
                    if(row_data.length > 0) {
                        table_model.addRowData(-1, row_data);
                    }
                }

                Connections
                {
                    target: organization_dialog
                    function onInitProperties() {
                        connections_table.load_data();
                    }
                }

                OrganizationConnectionDialog
                {
                    id: organization_connection_dialog
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
                    if(!database.deleteConnection(pk)) {
                        setStatusMessage(qsTr("Couldn't delete connection."), Enums.StatusMsgLvl.Err);
                    }
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_website
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Website")
                value: property_website
                derivative_value: undefined
                derivative_mode: true
                derivative_flag: (value === undefined) ? true : organization_dialog.property_website_derivative_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) connections_table.setFocus(dir);
                    else property_paragraph_edit_note.setFocus(dir);
                }

                Connections {
                    target: organization_dialog
                    function onInitProperties() {
                        property_line_edit_website.derivative_flag = Qt.binding(function() { return (property_line_edit_website.value === undefined) ? true : organization_dialog.property_website_derivative_flag; })
                        
                        property_line_edit_website.value = property_website;
                        property_line_edit_website.derivative_value = property_website_derivative;

                        property_line_edit_website.init();
                    }
                }

                onNew_value: function new_value(value, derivative_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_website = value;
                    else property_website = undefined;

                    organization_dialog.property_website_derivative_flag = derivative_flag;
                }
            }

            PropertyParagraphEdit
            {
                id: property_paragraph_edit_note
                width: parent.width
                height: ((parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count) * 3
                description: qsTr("Note")
                value: property_note
                original_value: ""
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_website.setFocus(dir);
                    else parent.nextFocus(dir);
                }

                Connections {
                    target: organization_dialog
                    function onInitProperties() {
                        property_paragraph_edit_note.original_value = property_note;
                    }
                }

                onNew_value: function new_value(value, derivative_flag) {
                    unsaved_changes = true;
                    property_note = value;
                }
            }
        }
    }
}