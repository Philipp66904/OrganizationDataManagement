import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"

import tablemodule 1.0

TemplateEditDialog
{
    id: address_dialog
    required property int pk_id
    identifier: pk_id
    parent_identifier: parent_id
    entry_name: qsTr("New Entry")
    window_title: qsTr("Add / Edit Address")
    title_name: qsTr("Address")
    table_name: "address"
    property string table_name_other: "address_other"
    property var parent_id: undefined
    property string qml_file_name: "AddressEditDialog.qml"
    property_height: 0.8

    onClosing: max_derivate_windows++;

    // current property values
    property string property_name: ""
    property string property_note: ""
    property var property_title: ""
    property bool property_title_derivate_flag: false
    property var property_title_derivate: undefined

    ListModel
    {
        id: address_other_list_model
    }

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        max_derivate_windows--;

        let entry_name_tmp = "New Entry";
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", address_dialog.table_name);
        address_dialog.entry_name = entry_name_tmp;

        // init properties
        address_dialog.property_name = (identifier >= 0) ? database.getName_byPk(identifier, "id", address_dialog.table_name) : "";
        address_dialog.property_note = (identifier >= 0) ? database.getNote_byPk(identifier, "id", address_dialog.table_name) : "";
        
        if(identifier >= 0) {
            // const property_title_tmp = database.getData(identifier, "id", "title", address_dialog.table_name);
            // address_dialog.property_title = property_title_tmp[0];
            // address_dialog.property_title_derivate_flag = property_title_tmp[1];
            // address_dialog.property_title_derivate = database.getDataDerivate(identifier, "id", "title", address_dialog.table_name)[0];
        }
        else if(parent_identifier !== undefined && parent_identifier >= 0) {
            // const property_title_tmp = database.getData(parent_identifier, "id", "title", address_dialog.table_name);
            // address_dialog.property_title = property_title_tmp[0];
            // address_dialog.property_title_derivate_flag = true;
            // address_dialog.property_title_derivate = database.getDataDerivate(parent_identifier, "id", "title", address_dialog.table_name)[0];
        }
        else {
            // address_dialog.property_title = undefined;
            // address_dialog.property_title_derivate_flag = false;
            // address_dialog.property_title_derivate = undefined;
        }

        // init address_other properties
        address_other_list_model.clear();
        const address_other_tmp = database.getDataOther(pk_id, "id", address_dialog.table_name, "address_id", address_dialog.table_name_other);
        const address_other_parent_tmp = database.getDataOther(parent_id, "id", address_dialog.table_name, "address_id", address_dialog.table_name_other);

        for (let address_other_row of address_other_tmp) {
            let derivate_value_tmp = undefined;
            for (let address_other_parent_row of address_other_parent_tmp) {
                if (address_other_row[1] === address_other_parent_row[1]) {
                    derivate_value_tmp = address_other_parent_row[2];
                    break;
                }
            }

            if (derivate_value_tmp !== undefined) {
                address_other_list_model.append({"pk": address_other_row[0],
                                                "other_index": address_other_row[1],
                                                "property_value": address_other_row[2],
                                                "property_derivate_flag": address_other_row[3],
                                                "property_derivate": derivate_value_tmp,
                                                "property_derivate_undefined_flag": false});
            }
            else
            {
                address_other_list_model.append({"pk": address_other_row[0],
                                                "other_index": address_other_row[1],
                                                "property_value": address_other_row[2],
                                                "property_derivate_flag": address_other_row[3],
                                                "property_derivate": "",
                                                "property_derivate_undefined_flag": true});
            }
        }

        init();
    }

    onSave_button_clicked: {
        // TODO save address_other_list_model to db:
        //      Check if any changes were made to the others, if yes delete all others and create new

        if(identifier >= 0) {
            // Update existing entry
            error_message = database.setName_Note_byPk(property_name.trim(), property_note, identifier, "id", address_dialog.table_name);
            if(error_message !== "") return;

            const address_array = []
            for(let i = 0; i < address_other_list_model.count; i++) {
                let address_other = address_other_list_model.get(i);

                const changes_obj = {}
                for (var attribute in address_other) {
                    changes_obj[attribute] = address_other[attribute];
                }
                changes_obj["other_index"] = i;

                if(changes_obj["property_derivate_flag"] === false) {
                    address_array.push(changes_obj);
                }
            }
            error_message = database.setOther(identifier, "address_id", "address_other", address_array);
            if(error_message !== "") return;

            // let new_title = undefined;
            // if(!property_title_derivate_flag) new_title = property_title;
            // error_message = database.setValue_Str("title", identifier, "id", address_dialog.table_name, new_title);
            // if(error_message !== "") return;
        }
        else {
            // Create new entry
            // let new_title = undefined;
            // if(!property_title_derivate_flag) new_title = property_title;
            
            // error_message = database.createPerson(property_name.trim(), property_note, new_parent_id,
            //                                       [new_title, new_gender, new_firstname, new_middlename, new_surname]);
            // if(error_message !== "") return;
        }
    }

    onDerivate_add_button_clicked: function derivate_add_button_clicked() {
        create_derivate_window(-1, qml_file_name);
    }

    onDerivate_edit_button_clicked: function derivate_edit_button_clicked(pk) {
        create_derivate_window(pk, qml_file_name);
    }

    Component
    {
        id: property_component

        Column
        {
            id: property_column
            spacing: 8
            property var row_count: 3
            property var row_height_count: 7

            PropertyLineEdit
            {
                id: property_line_edit_name
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Name")
                value: property_name
                derivate_value: ""
                derivate_mode: false

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_line_edit_name.derivate_value = property_name;
                    }
                }

                onNew_value: function new_value(value, derivate_flag) {
                    property_name = value;

                    if(identifier < 0 && value.trim() === "") address_dialog.entry_name = "New Entry";
                    else address_dialog.entry_name = value.trim();
                }
            }

            Rectangle
            {
                id: address_other_root
                color: "transparent"
                border.color: backgroundColor3
                border.width: 1
                width: parent.width
                height: ((parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count) * 3
                radius: 4

                Column
                {
                    id: address_other_column
                    spacing: 4
                    width: parent.width - 8
                    height: parent.height - 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    property int row_count: 4

                    // heights
                    property var address_other_description_text_height: (height - (spacing * (row_count - 1))) * 0.15
                    property var address_other_list_view_height: (height - (spacing * (row_count - 1))) * 0.67
                    property var address_other_button_row_height: (height - (spacing * (row_count - 1))) * 0.18 - address_other_separator_rect.height

                    Text
                    {
                        id: address_other_description_text
                        width: parent.width
                        height: parent.address_other_description_text_height
                        text: qsTr("Other:")
                        font.pointSize: textSize
                        color: backgroundColor3
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    ListView
                    {
                        id: address_other_list_view
                        width: parent.width
                        height: address_other_column.address_other_list_view_height
                        model: address_other_list_model
                        clip: true
                        delegate: property_other_component
                        spacing: 4

                        Component
                        {
                            id: property_other_component

                            PropertyLineEdit
                            {
                                id: property_line_edit_other
                                width: property_column.width
                                height: address_other_list_view.height * 0.35
                                description: qsTr("Other ") + (index + 1)
                                value: property_value
                                derivate_value: undefined
                                derivate_mode: true
                                derivate_flag: (value === undefined) ? true : property_derivate_flag
                                border.color: (editing) ? highlightColor : backgroundColor1

                                required property int index
                                required property int pk
                                required property int other_index
                                required property var property_value
                                required property bool property_derivate_flag
                                required property var property_derivate
                                required property bool property_derivate_undefined_flag

                                Component.onCompleted: {
                                    property_line_edit_other.derivate_flag = Qt.binding(function() { return (property_line_edit_other.value === undefined) ? true : property_derivate_flag; })
                                    
                                    property_line_edit_other.value = property_value;

                                    if(!property_derivate_undefined_flag) {
                                        property_line_edit_other.derivate_value = property_derivate;
                                    }
                                    else {
                                        property_line_edit_other.derivate_value = undefined;
                                    }
                                }

                                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                                    if (!undefined_flag) {
                                        address_other_list_model.set(index, {"property_value": value});
                                        property_line_edit_other.property_value = value;
                                    }
                                    else {
                                        address_other_list_model.set(index, {"property_value": undefined});
                                        property_line_edit_other.property_value = undefined;
                                    }

                                    address_other_list_model.set(index, {"property_derivate_flag": derivate_flag});
                                    property_line_edit_other.property_derivate_flag = derivate_flag;

                                    if(derivate_flag && property_derivate.length === 0) {
                                        address_other_list_model.remove(index, 1);
                                    }
                                }
                            }
                        }
                    }

                    Rectangle
                    {
                        id: address_other_separator_rect
                        height: 1
                        width: address_other_root.width - (address_other_root.border.width * 2)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: backgroundColor1
                    }

                    Row
                    {
                        id: address_other_button_row
                        width: parent.width
                        height: address_other_column.address_other_button_row_height
                        spacing: 8
                        property int column_count: 1

                        BasicButton
                        {
                            id: add_button
                            width: (parent.width - ((address_other_button_row.column_count - 1) * parent.spacing)) / address_other_button_row.column_count
                            height: parent.height
                            hover_color: highlight_color
                            text: qsTr("Add")
                            button_enabled: true

                            onClicked:
                            {
                                address_other_list_model.append({"pk": -1,
                                                                 "other_index": -1,
                                                                 "property_value": "",
                                                                 "property_derivate_flag": false,
                                                                 "property_derivate": "",
                                                                 "property_derivate_undefined_flag": true});
                            }
                        }
                    }
                }
            }

            // PropertyLineEdit
            // {
            //     id: property_line_edit_title
            //     width: parent.width
            //     height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
            //     description: qsTr("Title")
            //     value: property_title
            //     derivate_value: undefined
            //     derivate_mode: true
            //     derivate_flag: (value === undefined) ? true : address_dialog.property_title_derivate_flag

            //     Connections {
            //         target: address_dialog
            //         function onInitProperties() {
            //             property_line_edit_title.derivate_flag = Qt.binding(function() { return (property_line_edit_title.value === undefined) ? true : address_dialog.property_title_derivate_flag; })
                        
            //             property_line_edit_title.value = property_title;
            //             property_line_edit_title.derivate_value = property_title_derivate;
            //         }
            //     }

            //     onNew_value: function new_value(value, derivate_flag, undefined_flag) {
            //         if (!undefined_flag) property_title = value;
            //         else property_title = undefined;

            //         address_dialog.property_title_derivate_flag = derivate_flag;
            //     }
            // }

            PropertyParagraphEdit
            {
                id: property_paragraph_edit_note
                width: parent.width
                height: ((parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count) * 3
                description: qsTr("Note")
                value: property_note
                original_value: ""
                derivate_mode: false

                Connections {
                    target: address_dialog
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