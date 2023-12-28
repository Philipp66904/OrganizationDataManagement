import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"

import tablemodule 1.0

TemplateEditDialog
{
    id: person_dialog
    required property int pk_id
    identifier: pk_id
    parent_identifier: parent_id
    entry_name: qsTr("New Entry")
    window_title: qsTr("Add / Edit Person")
    title_name: qsTr("Person")
    table_name: "person"
    property var parent_id: undefined
    property string qml_file_name: "PersonEditDialog.qml"
    property_height: 0.8

    onClosing: max_derivate_windows++;

    // current property values
    property string property_name: ""
    property string property_note: ""
    property var property_title: ""
    property bool property_title_derivate_flag: false
    property var property_title_derivate: undefined
    property var property_gender: ""
    property bool property_gender_derivate_flag: false
    property var property_gender_derivate: undefined
    property var property_firstname: ""
    property bool property_firstname_derivate_flag: false
    property var property_firstname_derivate: undefined
    property var property_middlename: ""
    property bool property_middlename_derivate_flag: false
    property var property_middlename_derivate: undefined
    property var property_surname: ""
    property bool property_surname_derivate_flag: false
    property var property_surname_derivate: undefined

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        max_derivate_windows--;

        let entry_name_tmp = "New Entry";
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", person_dialog.table_name);
        person_dialog.entry_name = entry_name_tmp;

        // init properties
        person_dialog.property_name = (identifier >= 0) ? database.getName_byPk(identifier, "id", person_dialog.table_name) : "";
        person_dialog.property_note = (identifier >= 0) ? database.getNote_byPk(identifier, "id", person_dialog.table_name) : "";
        
        if(identifier >= 0) {
            const property_title_tmp = database.getData(identifier, "id", "title", person_dialog.table_name);
            person_dialog.property_title = property_title_tmp[0];
            person_dialog.property_title_derivate_flag = property_title_tmp[1];
            person_dialog.property_title_derivate = database.getDataDerivate(identifier, "id", "title", person_dialog.table_name)[0];

            const property_gender_tmp = database.getData(identifier, "id", "gender", person_dialog.table_name);
            person_dialog.property_gender = property_gender_tmp[0];
            person_dialog.property_gender_derivate_flag = property_gender_tmp[1];
            person_dialog.property_gender_derivate = database.getDataDerivate(identifier, "id", "gender", person_dialog.table_name)[0];

            const property_firstname_tmp = database.getData(identifier, "id", "firstname", person_dialog.table_name);
            person_dialog.property_firstname = property_firstname_tmp[0];
            person_dialog.property_firstname_derivate_flag = property_firstname_tmp[1];
            person_dialog.property_firstname_derivate = database.getDataDerivate(identifier, "id", "firstname", person_dialog.table_name)[0];

            const property_middlename_tmp = database.getData(identifier, "id", "middlename", person_dialog.table_name);
            person_dialog.property_middlename = property_middlename_tmp[0];
            person_dialog.property_middlename_derivate_flag = property_middlename_tmp[1];
            person_dialog.property_middlename_derivate = database.getDataDerivate(identifier, "id", "middlename", person_dialog.table_name)[0];

            const property_surname_tmp = database.getData(identifier, "id", "surname", person_dialog.table_name);
            person_dialog.property_surname = property_surname_tmp[0];
            person_dialog.property_surname_derivate_flag = property_surname_tmp[1];
            person_dialog.property_surname_derivate = database.getDataDerivate(identifier, "id", "surname", person_dialog.table_name)[0];
        }
        else if(parent_identifier !== undefined && parent_identifier >= 0) {
            const property_title_tmp = database.getData(parent_identifier, "id", "title", person_dialog.table_name);
            person_dialog.property_title = property_title_tmp[0];
            person_dialog.property_title_derivate_flag = true;
            person_dialog.property_title_derivate = database.getDataDerivate(parent_identifier, "id", "title", person_dialog.table_name)[0];

            const property_gender_tmp = database.getData(parent_identifier, "id", "gender", person_dialog.table_name);
            person_dialog.property_gender = property_gender_tmp[0];
            person_dialog.property_gender_derivate_flag = true;
            person_dialog.property_gender_derivate = database.getDataDerivate(parent_identifier, "id", "gender", person_dialog.table_name)[0];

            const property_firstname_tmp = database.getData(parent_identifier, "id", "firstname", person_dialog.table_name);
            person_dialog.property_firstname = property_firstname_tmp[0];
            person_dialog.property_firstname_derivate_flag = true;
            person_dialog.property_firstname_derivate = database.getDataDerivate(parent_identifier, "id", "firstname", person_dialog.table_name)[0];

            const property_middlename_tmp = database.getData(parent_identifier, "id", "middlename", person_dialog.table_name);
            person_dialog.property_middlename = property_middlename_tmp[0];
            person_dialog.property_middlename_derivate_flag = true;
            person_dialog.property_middlename_derivate = database.getDataDerivate(parent_identifier, "id", "middlename", person_dialog.table_name)[0];

            const property_surname_tmp = database.getData(parent_identifier, "id", "surname", person_dialog.table_name);
            person_dialog.property_surname = property_surname_tmp[0];
            person_dialog.property_surname_derivate_flag = true;
            person_dialog.property_surname_derivate = database.getDataDerivate(parent_identifier, "id", "surname", person_dialog.table_name)[0];
        }
        else {
            person_dialog.property_title = undefined;
            person_dialog.property_title_derivate_flag = false;
            person_dialog.property_title_derivate = undefined;

            person_dialog.property_gender = undefined;
            person_dialog.property_gender_derivate_flag = false;
            person_dialog.property_gender_derivate = undefined;

            person_dialog.property_firstname = undefined;
            person_dialog.property_firstname_derivate_flag = false;
            person_dialog.property_firstname_derivate = undefined;

            person_dialog.property_middlename = undefined;
            person_dialog.property_middlename_derivate_flag = false;
            person_dialog.property_middlename_derivate = undefined;

            person_dialog.property_surname = undefined;
            person_dialog.property_surname_derivate_flag = false;
            person_dialog.property_surname_derivate = undefined;
        }

        init();
    }

    onSave_button_clicked: {
        if(identifier >= 0) {
            // Update existing entry
            error_message = database.setName_Note_byPk(property_name.trim(), property_note, identifier, "id", person_dialog.table_name);
            if(error_message !== "") return;

            let new_title = undefined;
            if(!property_title_derivate_flag) new_title = property_title;
            error_message = database.setValue_Str("title", identifier, "id", person_dialog.table_name, new_title);
            if(error_message !== "") return;

            let new_gender = undefined;
            if(!property_gender_derivate_flag) new_gender = property_gender;
            error_message = database.setValue_Str("gender", identifier, "id", person_dialog.table_name, new_gender);
            if(error_message !== "") return;

            let new_firstname = undefined;
            if(!property_firstname_derivate_flag) new_firstname = property_firstname;
            error_message = database.setValue_Str("firstname", identifier, "id", person_dialog.table_name, new_firstname);
            if(error_message !== "") return;

            let new_middlename = undefined;
            if(!property_middlename_derivate_flag) new_middlename = property_middlename;
            error_message = database.setValue_Str("middlename", identifier, "id", person_dialog.table_name, new_middlename);
            if(error_message !== "") return;

            let new_surname = undefined;
            if(!property_surname_derivate_flag) new_surname = property_surname;
            error_message = database.setValue_Str("surname", identifier, "id", person_dialog.table_name, new_surname);
            if(error_message !== "") return;
        }
        else {
            // Create new entry
            let new_title = undefined;
            if(!property_title_derivate_flag) new_title = property_title;

            let new_gender = undefined;
            if(!property_gender_derivate_flag) new_gender = property_gender;

            let new_firstname = undefined;
            if(!property_firstname_derivate_flag) new_firstname = property_firstname;

            let new_middlename = undefined;
            if(!property_middlename_derivate_flag) new_middlename = property_middlename;

            let new_surname = undefined;
            if(!property_surname_derivate_flag) new_surname = property_surname;

            let new_parent_id = -1;
            if(parent_identifier !== undefined) new_parent_id = parent_identifier;
            
            error_message = database.createPerson(property_name.trim(), property_note, new_parent_id,
                                                  [new_title, new_gender, new_firstname, new_middlename, new_surname]);
            if(error_message !== "") return;
        }
    }

    onDerivate_add_button_clicked: function derivate_add_button_clicked() {
        create_derivate_window(-1, qml_file_name);
    }

    onDerivate_edit_button_clicked: function derivate_edit_button_clicked(pk) {
        create_derivate_window(pk, qml_file_name);
    }

    onDerivate_duplicate_button_clicked: function derivate_duplicate_button_clicked(pk) {
        error_message = database.duplicateEntry(pk, "id", person_dialog.table_name);
        if(error_message !== "") return;
    }

    Component
    {
        id: property_component

        Column
        {
            spacing: 8
            property var row_count: 7
            property var row_height_count: 9

            PropertyLineEdit
            {
                id: property_line_edit_name
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Description name")
                value: property_name
                derivate_value: ""
                derivate_mode: false

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_name.derivate_value = property_name;
                    }
                }

                onNew_value: function new_value(value, derivate_flag) {
                    property_name = value;

                    if(identifier < 0 && value.trim() === "") person_dialog.entry_name = "New Entry";
                    else person_dialog.entry_name = value.trim();
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_title
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Title")
                value: property_title
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : person_dialog.property_title_derivate_flag

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_title.derivate_flag = Qt.binding(function() { return (property_line_edit_title.value === undefined) ? true : person_dialog.property_title_derivate_flag; })
                        
                        property_line_edit_title.value = property_title;
                        property_line_edit_title.derivate_value = property_title_derivate;
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    if (!undefined_flag) property_title = value;
                    else property_title = undefined;

                    person_dialog.property_title_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_gender
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Gender")
                value: property_gender
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : person_dialog.property_gender_derivate_flag

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_gender.derivate_flag = Qt.binding(function() { return (property_line_edit_gender.value === undefined) ? true : person_dialog.property_gender_derivate_flag; })
                        
                        property_line_edit_gender.value = property_gender;
                        property_line_edit_gender.derivate_value = property_gender_derivate;
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    if (!undefined_flag) property_gender = value;
                    else property_gender = undefined;

                    person_dialog.property_gender_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_firstname
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Firstname")
                value: property_firstname
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : person_dialog.property_firstname_derivate_flag

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_firstname.derivate_flag = Qt.binding(function() { return (property_line_edit_firstname.value === undefined) ? true : person_dialog.property_firstname_derivate_flag; })
                        
                        property_line_edit_firstname.value = property_firstname;
                        property_line_edit_firstname.derivate_value = property_firstname_derivate;
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    if (!undefined_flag) property_firstname = value;
                    else property_firstname = undefined;

                    person_dialog.property_firstname_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_middlename
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Middlename")
                value: property_middlename
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : person_dialog.property_middlename_derivate_flag

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_middlename.derivate_flag = Qt.binding(function() { return (property_line_edit_middlename.value === undefined) ? true : person_dialog.property_middlename_derivate_flag; })
                        
                        property_line_edit_middlename.value = property_middlename;
                        property_line_edit_middlename.derivate_value = property_middlename_derivate;
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    if (!undefined_flag) property_middlename = value;
                    else property_middlename = undefined;

                    person_dialog.property_middlename_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_surname
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Surname")
                value: property_surname
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : person_dialog.property_surname_derivate_flag

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_surname.derivate_flag = Qt.binding(function() { return (property_line_edit_surname.value === undefined) ? true : person_dialog.property_surname_derivate_flag; })
                        
                        property_line_edit_surname.value = property_surname;
                        property_line_edit_surname.derivate_value = property_surname_derivate;
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    if (!undefined_flag) property_surname = value;
                    else property_surname = undefined;

                    person_dialog.property_surname_derivate_flag = derivate_flag;
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
                derivate_mode: false

                Connections {
                    target: person_dialog
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