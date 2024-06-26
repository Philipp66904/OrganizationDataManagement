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
    id: person_dialog
    required property int pk_id
    identifier: pk_id
    parent_identifier: parent_id
    entry_name: qsTr("New Entry")
    window_title: (pk_id >= 0) ? qsTr("Edit Person") : qsTr("Add Person")
    title_name: qsTr("Person")
    table_name: "person"
    property var parent_id: undefined
    property string qml_file_name: "PersonEditDialog.qml"
    property_height: 0.8 * (480.0 / height)

    // current property values
    property string property_name: ""
    property string property_note: ""
    property var property_title: ""
    property bool property_title_derivative_flag: false
    property var property_title_derivative: undefined
    property var property_gender: ""
    property bool property_gender_derivative_flag: false
    property var property_gender_derivative: undefined
    property var property_firstname: ""
    property bool property_firstname_derivative_flag: false
    property var property_firstname_derivative: undefined
    property var property_middlename: ""
    property bool property_middlename_derivative_flag: false
    property var property_middlename_derivative: undefined
    property var property_surname: ""
    property bool property_surname_derivative_flag: false
    property var property_surname_derivative: undefined

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        let entry_name_tmp = qsTr("New Entry");
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", person_dialog.table_name);
        person_dialog.entry_name = entry_name_tmp.trim();

        // init properties
        person_dialog.property_name = (identifier >= 0) ? database.getName_byPk(identifier, "id", person_dialog.table_name) : "";
        person_dialog.property_note = (identifier >= 0) ? database.getNote_byPk(identifier, "id", person_dialog.table_name) : "";
        
        if(identifier >= 0) {
            const property_title_tmp = database.getData(identifier, "id", "title", person_dialog.table_name);
            person_dialog.property_title = property_title_tmp[0];
            person_dialog.property_title_derivative_flag = property_title_tmp[1];
            person_dialog.property_title_derivative = database.getDataDerivative(identifier, "id", "title", person_dialog.table_name)[0];

            const property_gender_tmp = database.getData(identifier, "id", "gender", person_dialog.table_name);
            person_dialog.property_gender = property_gender_tmp[0];
            person_dialog.property_gender_derivative_flag = property_gender_tmp[1];
            person_dialog.property_gender_derivative = database.getDataDerivative(identifier, "id", "gender", person_dialog.table_name)[0];

            const property_firstname_tmp = database.getData(identifier, "id", "firstname", person_dialog.table_name);
            person_dialog.property_firstname = property_firstname_tmp[0];
            person_dialog.property_firstname_derivative_flag = property_firstname_tmp[1];
            person_dialog.property_firstname_derivative = database.getDataDerivative(identifier, "id", "firstname", person_dialog.table_name)[0];

            const property_middlename_tmp = database.getData(identifier, "id", "middlename", person_dialog.table_name);
            person_dialog.property_middlename = property_middlename_tmp[0];
            person_dialog.property_middlename_derivative_flag = property_middlename_tmp[1];
            person_dialog.property_middlename_derivative = database.getDataDerivative(identifier, "id", "middlename", person_dialog.table_name)[0];

            const property_surname_tmp = database.getData(identifier, "id", "surname", person_dialog.table_name);
            person_dialog.property_surname = property_surname_tmp[0];
            person_dialog.property_surname_derivative_flag = property_surname_tmp[1];
            person_dialog.property_surname_derivative = database.getDataDerivative(identifier, "id", "surname", person_dialog.table_name)[0];
        }
        else if(parent_identifier !== undefined && parent_identifier >= 0) {
            const property_title_tmp = database.getData(parent_identifier, "id", "title", person_dialog.table_name);
            person_dialog.property_title = property_title_tmp[0];
            person_dialog.property_title_derivative_flag = true;
            person_dialog.property_title_derivative = property_title_tmp[0];

            const property_gender_tmp = database.getData(parent_identifier, "id", "gender", person_dialog.table_name);
            person_dialog.property_gender = property_gender_tmp[0];
            person_dialog.property_gender_derivative_flag = true;
            person_dialog.property_gender_derivative = property_gender_tmp[0];

            const property_firstname_tmp = database.getData(parent_identifier, "id", "firstname", person_dialog.table_name);
            person_dialog.property_firstname = property_firstname_tmp[0];
            person_dialog.property_firstname_derivative_flag = true;
            person_dialog.property_firstname_derivative = property_firstname_tmp[0];

            const property_middlename_tmp = database.getData(parent_identifier, "id", "middlename", person_dialog.table_name);
            person_dialog.property_middlename = property_middlename_tmp[0];
            person_dialog.property_middlename_derivative_flag = true;
            person_dialog.property_middlename_derivative = property_middlename_tmp[0];

            const property_surname_tmp = database.getData(parent_identifier, "id", "surname", person_dialog.table_name);
            person_dialog.property_surname = property_surname_tmp[0];
            person_dialog.property_surname_derivative_flag = true;
            person_dialog.property_surname_derivative = property_surname_tmp[0];
        }
        else {
            person_dialog.property_title = undefined;
            person_dialog.property_title_derivative_flag = false;
            person_dialog.property_title_derivative = undefined;

            person_dialog.property_gender = undefined;
            person_dialog.property_gender_derivative_flag = false;
            person_dialog.property_gender_derivative = undefined;

            person_dialog.property_firstname = undefined;
            person_dialog.property_firstname_derivative_flag = false;
            person_dialog.property_firstname_derivative = undefined;

            person_dialog.property_middlename = undefined;
            person_dialog.property_middlename_derivative_flag = false;
            person_dialog.property_middlename_derivative = undefined;

            person_dialog.property_surname = undefined;
            person_dialog.property_surname_derivative_flag = false;
            person_dialog.property_surname_derivative = undefined;
        }

        init();
    }

    onSave_button_clicked: {
        if(identifier >= 0) {
            // Update existing entry
            let msg = setStatusMessage(database.setName_Note_byPk(property_name, property_note, identifier, "id", person_dialog.table_name), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_title = undefined;
            if(!property_title_derivative_flag) new_title = property_title;
            msg = setStatusMessage(database.setValue_Str("title", identifier, "id", person_dialog.table_name, new_title), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_gender = undefined;
            if(!property_gender_derivative_flag) new_gender = property_gender;
            msg = setStatusMessage(database.setValue_Str("gender", identifier, "id", person_dialog.table_name, new_gender), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_firstname = undefined;
            if(!property_firstname_derivative_flag) new_firstname = property_firstname;
            msg = setStatusMessage(database.setValue_Str("firstname", identifier, "id", person_dialog.table_name, new_firstname), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_middlename = undefined;
            if(!property_middlename_derivative_flag) new_middlename = property_middlename;
            msg = setStatusMessage(database.setValue_Str("middlename", identifier, "id", person_dialog.table_name, new_middlename), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_surname = undefined;
            if(!property_surname_derivative_flag) new_surname = property_surname;
            msg = setStatusMessage(database.setValue_Str("surname", identifier, "id", person_dialog.table_name, new_surname), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;
        }
        else {
            // Create new entry
            let new_title = undefined;
            if(!property_title_derivative_flag) new_title = property_title;

            let new_gender = undefined;
            if(!property_gender_derivative_flag) new_gender = property_gender;

            let new_firstname = undefined;
            if(!property_firstname_derivative_flag) new_firstname = property_firstname;

            let new_middlename = undefined;
            if(!property_middlename_derivative_flag) new_middlename = property_middlename;

            let new_surname = undefined;
            if(!property_surname_derivative_flag) new_surname = property_surname;

            let new_parent_id = -1;
            if(parent_identifier !== undefined) new_parent_id = parent_identifier;
            
            const msg = setStatusMessage(database.createPerson(property_name, property_note, new_parent_id,
                                            [new_title, new_gender, new_firstname, new_middlename, new_surname]),
                                         Enums.StatusMsgLvl.Err);
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
        const msg = setStatusMessage(database.duplicateEntry(pk, "id", person_dialog.table_name), Enums.StatusMsgLvl.Err);
        if(msg !== "") return;
    }

    Component
    {
        id: property_component

        Column
        {
            spacing: 8
            property var row_count: 7
            property var row_height_count: 9 * (height / 384.0)

            function setFocus(dir) {
                if(dir === Enums.FocusDir.Down || dir === Enums.FocusDir.Right) property_line_edit_name.setFocus(dir);
                else property_paragraph_edit_note.setFocus(dir);
            }

            signal nextFocus(dir: int)
            signal scrollTo(y_coord_top: real, y_coord_bot: real)

            PropertyLineEdit
            {
                id: property_line_edit_name
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Entry Name")
                value: property_name
                derivative_value: ""
                derivative_mode: false
                required: true
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) parent.nextFocus(dir);
                    else property_line_edit_title.setFocus(dir);
                }

                onFocusSet: scrollTo(y, y + height);

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_name.derivative_value = property_name;
                        person_dialog.save_button_enabled = (property_name.trim().length > 0);
                    }
                }

                onNew_value: function new_value(value, derivative_flag) {
                    unsaved_changes = true;
                    property_name = value;

                    if(identifier < 0 && value.trim() === "") person_dialog.entry_name = qsTr("New Entry");
                    else person_dialog.entry_name = value.trim();

                    person_dialog.save_button_enabled = (property_name.trim().length > 0);
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_title
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Title")
                value: property_title
                derivative_value: undefined
                derivative_mode: true
                derivative_flag: (value === undefined) ? true : person_dialog.property_title_derivative_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_name.setFocus(dir);
                    else property_line_edit_gender.setFocus(dir);
                }

                onFocusSet: scrollTo(y, y + height);

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_title.derivative_flag = Qt.binding(function() { return (property_line_edit_title.value === undefined) ? true : person_dialog.property_title_derivative_flag; })
                        
                        property_line_edit_title.value = property_title;
                        property_line_edit_title.derivative_value = property_title_derivative;

                        property_line_edit_title.init();
                    }
                }

                onNew_value: function new_value(value, derivative_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_title = value;
                    else property_title = undefined;

                    person_dialog.property_title_derivative_flag = derivative_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_gender
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Gender")
                value: property_gender
                derivative_value: undefined
                derivative_mode: true
                derivative_flag: (value === undefined) ? true : person_dialog.property_gender_derivative_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_title.setFocus(dir);
                    else property_line_edit_firstname.setFocus(dir);
                }

                onFocusSet: scrollTo(y, y + height);

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_gender.derivative_flag = Qt.binding(function() { return (property_line_edit_gender.value === undefined) ? true : person_dialog.property_gender_derivative_flag; })
                        
                        property_line_edit_gender.value = property_gender;
                        property_line_edit_gender.derivative_value = property_gender_derivative;

                        property_line_edit_gender.init();
                    }
                }

                onNew_value: function new_value(value, derivative_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_gender = value;
                    else property_gender = undefined;

                    person_dialog.property_gender_derivative_flag = derivative_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_firstname
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Firstname")
                value: property_firstname
                derivative_value: undefined
                derivative_mode: true
                derivative_flag: (value === undefined) ? true : person_dialog.property_firstname_derivative_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_gender.setFocus(dir);
                    else property_line_edit_middlename.setFocus(dir);
                }

                onFocusSet: scrollTo(y, y + height);

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_firstname.derivative_flag = Qt.binding(function() { return (property_line_edit_firstname.value === undefined) ? true : person_dialog.property_firstname_derivative_flag; })
                        
                        property_line_edit_firstname.value = property_firstname;
                        property_line_edit_firstname.derivative_value = property_firstname_derivative;

                        property_line_edit_firstname.init();
                    }
                }

                onNew_value: function new_value(value, derivative_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_firstname = value;
                    else property_firstname = undefined;

                    person_dialog.property_firstname_derivative_flag = derivative_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_middlename
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Middlename")
                value: property_middlename
                derivative_value: undefined
                derivative_mode: true
                derivative_flag: (value === undefined) ? true : person_dialog.property_middlename_derivative_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_firstname.setFocus(dir);
                    else property_line_edit_surname.setFocus(dir);
                }

                onFocusSet: scrollTo(y, y + height);

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_middlename.derivative_flag = Qt.binding(function() { return (property_line_edit_middlename.value === undefined) ? true : person_dialog.property_middlename_derivative_flag; })
                        
                        property_line_edit_middlename.value = property_middlename;
                        property_line_edit_middlename.derivative_value = property_middlename_derivative;

                        property_line_edit_middlename.init();
                    }
                }

                onNew_value: function new_value(value, derivative_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_middlename = value;
                    else property_middlename = undefined;

                    person_dialog.property_middlename_derivative_flag = derivative_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_surname
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Surname")
                value: property_surname
                derivative_value: undefined
                derivative_mode: true
                derivative_flag: (value === undefined) ? true : person_dialog.property_surname_derivative_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_middlename.setFocus(dir);
                    else property_paragraph_edit_note.setFocus(dir);
                }

                onFocusSet: scrollTo(y, y + height);

                Connections {
                    target: person_dialog
                    function onInitProperties() {
                        property_line_edit_surname.derivative_flag = Qt.binding(function() { return (property_line_edit_surname.value === undefined) ? true : person_dialog.property_surname_derivative_flag; })
                        
                        property_line_edit_surname.value = property_surname;
                        property_line_edit_surname.derivative_value = property_surname_derivative;

                        property_line_edit_surname.init();
                    }
                }

                onNew_value: function new_value(value, derivative_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_surname = value;
                    else property_surname = undefined;

                    person_dialog.property_surname_derivative_flag = derivative_flag;
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
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_surname.setFocus(dir);
                    else parent.nextFocus(dir);
                }

                onFocusSet: scrollTo(y, y + height);

                Connections {
                    target: person_dialog
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