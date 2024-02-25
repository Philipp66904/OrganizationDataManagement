import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../components"
import "../types"

import tablemodule 1.0

TemplateEditDialog
{
    id: address_dialog
    required property int pk_id
    identifier: pk_id
    parent_identifier: parent_id
    entry_name: qsTr("New Entry")
    window_title: (pk_id >= 0) ? qsTr("Edit Address") : qsTr("Add Address")
    title_name: qsTr("Address")
    table_name: "address"
    property string table_name_other: "address_other"
    property var parent_id: undefined
    property string qml_file_name: "AddressEditDialog.qml"
    property_height: 1.2

    // current property values
    property string property_name: ""
    property string property_note: ""
    property var property_street: ""
    property bool property_street_derivate_flag: false
    property var property_street_derivate: undefined
    property var property_number: ""
    property bool property_number_derivate_flag: false
    property var property_number_derivate: undefined
    property var property_postalcode: ""
    property bool property_postalcode_derivate_flag: false
    property var property_postalcode_derivate: undefined
    property var property_city: ""
    property bool property_city_derivate_flag: false
    property var property_city_derivate: undefined
    property var property_state: ""
    property bool property_state_derivate_flag: false
    property var property_state_derivate: undefined
    property var property_country: ""
    property bool property_country_derivate_flag: false
    property var property_country_derivate: undefined

    ListModel
    {
        id: address_other_list_model
    }

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        let entry_name_tmp = qsTr("New Entry");
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", address_dialog.table_name);
        address_dialog.entry_name = entry_name_tmp.trim();

        // init properties
        address_dialog.property_name = (identifier >= 0) ? database.getName_byPk(identifier, "id", address_dialog.table_name) : "";
        address_dialog.property_note = (identifier >= 0) ? database.getNote_byPk(identifier, "id", address_dialog.table_name) : "";

        if(identifier >= 0) {
            const property_street_tmp = database.getData(identifier, "id", "street", address_dialog.table_name);
            address_dialog.property_street = property_street_tmp[0];
            address_dialog.property_street_derivate_flag = property_street_tmp[1];
            address_dialog.property_street_derivate = database.getDataDerivate(identifier, "id", "street", address_dialog.table_name)[0];

            const property_number_tmp = database.getData(identifier, "id", "number", address_dialog.table_name);
            address_dialog.property_number = property_number_tmp[0];
            address_dialog.property_number_derivate_flag = property_number_tmp[1];
            address_dialog.property_number_derivate = database.getDataDerivate(identifier, "id", "number", address_dialog.table_name)[0];

            const property_postalcode_tmp = database.getData(identifier, "id", "postalcode", address_dialog.table_name);
            address_dialog.property_postalcode = property_postalcode_tmp[0];
            address_dialog.property_postalcode_derivate_flag = property_postalcode_tmp[1];
            address_dialog.property_postalcode_derivate = database.getDataDerivate(identifier, "id", "postalcode", address_dialog.table_name)[0];

            const property_city_tmp = database.getData(identifier, "id", "city", address_dialog.table_name);
            address_dialog.property_city = property_city_tmp[0];
            address_dialog.property_city_derivate_flag = property_city_tmp[1];
            address_dialog.property_city_derivate = database.getDataDerivate(identifier, "id", "city", address_dialog.table_name)[0];

            const property_state_tmp = database.getData(identifier, "id", "state", address_dialog.table_name);
            address_dialog.property_state = property_state_tmp[0];
            address_dialog.property_state_derivate_flag = property_state_tmp[1];
            address_dialog.property_state_derivate = database.getDataDerivate(identifier, "id", "state", address_dialog.table_name)[0];

            const property_country_tmp = database.getData(identifier, "id", "country", address_dialog.table_name);
            address_dialog.property_country = property_country_tmp[0];
            address_dialog.property_country_derivate_flag = property_country_tmp[1];
            address_dialog.property_country_derivate = database.getDataDerivate(identifier, "id", "country", address_dialog.table_name)[0];
        }
        else if(parent_identifier !== undefined && parent_identifier >= 0) {
            const property_street_tmp = database.getData(parent_identifier, "id", "street", address_dialog.table_name);
            address_dialog.property_street = property_street_tmp[0];
            address_dialog.property_street_derivate_flag = true;
            address_dialog.property_street_derivate = property_street_tmp[0]

            const property_number_tmp = database.getData(parent_identifier, "id", "number", address_dialog.table_name);
            address_dialog.property_number = property_number_tmp[0];
            address_dialog.property_number_derivate_flag = true;
            address_dialog.property_number_derivate = property_number_tmp[0];

            const property_postalcode_tmp = database.getData(parent_identifier, "id", "postalcode", address_dialog.table_name);
            address_dialog.property_postalcode = property_postalcode_tmp[0];
            address_dialog.property_postalcode_derivate_flag = true;
            address_dialog.property_postalcode_derivate = property_postalcode_tmp[0];

            const property_city_tmp = database.getData(parent_identifier, "id", "city", address_dialog.table_name);
            address_dialog.property_city = property_city_tmp[0];
            address_dialog.property_city_derivate_flag = true;
            address_dialog.property_city_derivate = property_city_tmp[0];

            const property_state_tmp = database.getData(parent_identifier, "id", "state", address_dialog.table_name);
            address_dialog.property_state = property_state_tmp[0];
            address_dialog.property_state_derivate_flag = true;
            address_dialog.property_state_derivate = property_state_tmp[0];

            const property_country_tmp = database.getData(parent_identifier, "id", "country", address_dialog.table_name);
            address_dialog.property_country = property_country_tmp[0];
            address_dialog.property_country_derivate_flag = true;
            address_dialog.property_country_derivate = property_country_tmp[0];
        }
        else {
            address_dialog.property_street = undefined;
            address_dialog.property_street_derivate_flag = false;
            address_dialog.property_street_derivate = undefined;

            address_dialog.property_number = undefined;
            address_dialog.property_number_derivate_flag = false;
            address_dialog.property_number_derivate = undefined;

            address_dialog.property_postalcode = undefined;
            address_dialog.property_postalcode_derivate_flag = false;
            address_dialog.property_postalcode_derivate = undefined;

            address_dialog.property_city = undefined;
            address_dialog.property_city_derivate_flag = false;
            address_dialog.property_city_derivate = undefined;

            address_dialog.property_state = undefined;
            address_dialog.property_state_derivate_flag = false;
            address_dialog.property_state_derivate = undefined;

            address_dialog.property_country = undefined;
            address_dialog.property_country_derivate_flag = false;
            address_dialog.property_country_derivate = undefined;
        }

        // init address_other properties
        address_other_list_model.clear();

        if(identifier >= 0) {
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
        }
        else if(parent_identifier !== undefined && parent_identifier >= 0) {
            const address_other_parent_tmp = database.getDataOther(parent_identifier, "id", address_dialog.table_name, "address_id", address_dialog.table_name_other);

            for (let address_other_row of address_other_parent_tmp) {
                address_other_list_model.append({"pk": address_other_row[0],
                                                 "other_index": address_other_row[1],
                                                 "property_value": address_other_row[2],
                                                 "property_derivate_flag": true,
                                                 "property_derivate": address_other_row[2],
                                                 "property_derivate_undefined_flag": false});
            }
        }

        init();
    }

    onSave_button_clicked: {
        // Get all 'other' address contents in specific format
        const address_other_array = []
        for(let i = 0; i < address_other_list_model.count; i++) {
            let address_other = address_other_list_model.get(i);

            const changes_obj = {}
            for (var attribute in address_other) {
                changes_obj[attribute] = address_other[attribute];
            }
            changes_obj["other_index"] = i;

            if(changes_obj["property_derivate_flag"] === false) {
                address_other_array.push(changes_obj);
            }
        }

        // Save address
        if(identifier >= 0) {
            // Update existing entry
            let msg = setStatusMessage(database.setName_Note_byPk(property_name, property_note, identifier, "id", address_dialog.table_name), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            msg = setStatusMessage(database.setOther(identifier, "address_id", "address_other", address_other_array), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_street = undefined;
            if(!property_street_derivate_flag) new_street = property_street;
            msg = setStatusMessage(database.setValue_Str("street", identifier, "id", address_dialog.table_name, new_street), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_number = undefined;
            if(!property_number_derivate_flag) new_number = property_number;
            msg = setStatusMessage(database.setValue_Str("number", identifier, "id", address_dialog.table_name, new_number), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_postalcode = undefined;
            if(!property_postalcode_derivate_flag) new_postalcode = property_postalcode;
            msg = setStatusMessage(database.setValue_Str("postalcode", identifier, "id", address_dialog.table_name, new_postalcode), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_city = undefined;
            if(!property_city_derivate_flag) new_city = property_city;
            msg = setStatusMessage(database.setValue_Str("city", identifier, "id", address_dialog.table_name, new_city), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_state = undefined;
            if(!property_state_derivate_flag) new_state = property_state;
            msg = setStatusMessage(database.setValue_Str("state", identifier, "id", address_dialog.table_name, new_state), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;

            let new_country = undefined;
            if(!property_country_derivate_flag) new_country = property_country;
            msg = setStatusMessage(database.setValue_Str("country", identifier, "id", address_dialog.table_name, new_country), Enums.StatusMsgLvl.Err);
            if(msg !== "") return;
        }
        else {
            // Create new entry
            let new_street = undefined;
            if(!property_street_derivate_flag) new_street = property_street;

            let new_number = undefined;
            if(!property_number_derivate_flag) new_number = property_number;

            let new_postalcode = undefined;
            if(!property_postalcode_derivate_flag) new_postalcode = property_postalcode;

            let new_city = undefined;
            if(!property_city_derivate_flag) new_city = property_city;

            let new_state = undefined;
            if(!property_state_derivate_flag) new_state = property_state;

            let new_country = undefined;
            if(!property_country_derivate_flag) new_country = property_country;
            
            let new_parent_id = -1;
            if(parent_identifier !== undefined) new_parent_id = parent_identifier;

            const msg = setStatusMessage(database.createAddress(property_name, property_note, new_parent_id,
                                            [new_street, new_number, new_postalcode, new_city, new_state, new_country],
                                            address_other_array),
                                         Enums.StatusMsgLvl.Err);
            if(msg !== "") return;
        }

        unsaved_changes = false;
    }

    onDerivate_add_button_clicked: function derivate_add_button_clicked() {
        create_derivate_window(-1, qml_file_name);
    }

    onDerivate_edit_button_clicked: function derivate_edit_button_clicked(pk) {
        create_derivate_window(pk, qml_file_name);
    }

    onDerivate_duplicate_button_clicked: function derivate_duplicate_button_clicked(pk) {
        const msg = setStatusMessage(database.duplicateEntry(pk, "id", address_dialog.table_name, "address_id", "address_other"), Enums.StatusMsgLvl.Err);
        if(msg !== "") return;
    }

    Component
    {
        id: property_component

        Column
        {
            id: property_column
            spacing: 8
            property var row_count: 9
            property var row_height_count: 13

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
                derivate_value: ""
                derivate_mode: false
                required: true
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) parent.nextFocus(dir);
                    else property_line_edit_street.setFocus(dir);
                }

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_line_edit_name.derivate_value = property_name;
                        address_dialog.save_button_enabled = (property_name.trim().length > 0);
                    }
                }

                onNew_value: function new_value(value, derivate_flag) {
                    unsaved_changes = true;
                    property_name = value;

                    if(identifier < 0 && value.trim() === "") address_dialog.entry_name = qsTr("New Entry");
                    else address_dialog.entry_name = value.trim();

                    address_dialog.save_button_enabled = (property_name.trim().length > 0);
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_street
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Street")
                value: property_street
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : address_dialog.property_street_derivate_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_name.setFocus(dir);
                    else property_line_edit_number.setFocus(dir);
                }

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_line_edit_street.derivate_flag = Qt.binding(function() { return (property_line_edit_street.value === undefined) ? true : address_dialog.property_street_derivate_flag; })
                        
                        property_line_edit_street.value = property_street;
                        property_line_edit_street.derivate_value = property_street_derivate;

                        property_line_edit_street.init();
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_street = value;
                    else property_street = undefined;

                    address_dialog.property_street_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_number
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Number")
                value: property_number
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : address_dialog.property_number_derivate_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_street.setFocus(dir);
                    else property_line_edit_postalcode.setFocus(dir);
                }

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_line_edit_number.derivate_flag = Qt.binding(function() { return (property_line_edit_number.value === undefined) ? true : address_dialog.property_number_derivate_flag; })
                        
                        property_line_edit_number.value = property_number;
                        property_line_edit_number.derivate_value = property_number_derivate;

                        property_line_edit_number.init();
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_number = value;
                    else property_number = undefined;

                    address_dialog.property_number_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_postalcode
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Postalcode")
                value: property_postalcode
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : address_dialog.property_postalcode_derivate_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_number.setFocus(dir);
                    else property_line_edit_city.setFocus(dir);
                }

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_line_edit_postalcode.derivate_flag = Qt.binding(function() { return (property_line_edit_postalcode.value === undefined) ? true : address_dialog.property_postalcode_derivate_flag; })
                        
                        property_line_edit_postalcode.value = property_postalcode;
                        property_line_edit_postalcode.derivate_value = property_postalcode_derivate;

                        property_line_edit_postalcode.init();
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_postalcode = value;
                    else property_postalcode = undefined;

                    address_dialog.property_postalcode_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_city
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("City")
                value: property_city
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : address_dialog.property_city_derivate_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_postalcode.setFocus(dir);
                    else property_line_edit_state.setFocus(dir);
                }

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_line_edit_city.derivate_flag = Qt.binding(function() { return (property_line_edit_city.value === undefined) ? true : address_dialog.property_city_derivate_flag; })
                        
                        property_line_edit_city.value = property_city;
                        property_line_edit_city.derivate_value = property_city_derivate;

                        property_line_edit_city.init();
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_city = value;
                    else property_city = undefined;

                    address_dialog.property_city_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_state
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("State")
                value: property_state
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : address_dialog.property_state_derivate_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_city.setFocus(dir);
                    else property_line_edit_country.setFocus(dir);
                }

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_line_edit_state.derivate_flag = Qt.binding(function() { return (property_line_edit_state.value === undefined) ? true : address_dialog.property_state_derivate_flag; })
                        
                        property_line_edit_state.value = property_state;
                        property_line_edit_state.derivate_value = property_state_derivate;

                        property_line_edit_state.init();
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_state = value;
                    else property_state = undefined;

                    address_dialog.property_state_derivate_flag = derivate_flag;
                }
            }

            PropertyLineEdit
            {
                id: property_line_edit_country
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_height_count
                description: qsTr("Country")
                value: property_country
                derivate_value: undefined
                derivate_mode: true
                derivate_flag: (value === undefined) ? true : address_dialog.property_country_derivate_flag
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) parent.nextFocus(dir);
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) property_line_edit_state.setFocus(dir);
                    else address_other_list_view.setFocus(dir);
                }

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_line_edit_country.derivate_flag = Qt.binding(function() { return (property_line_edit_country.value === undefined) ? true : address_dialog.property_country_derivate_flag; })
                        
                        property_line_edit_country.value = property_country;
                        property_line_edit_country.derivate_value = property_country_derivate;

                        property_line_edit_country.init();
                    }
                }

                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                    unsaved_changes = true;
                    if (!undefined_flag) property_country = value;
                    else property_country = undefined;

                    address_dialog.property_country_derivate_flag = derivate_flag;
                }
            }

            Rectangle
            {
                id: address_other_root
                color: backgroundColor1
                border.color: backgroundColor2
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
                        color: textColor1
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
                        reuseItems: false
                        flickableDirection: Flickable.AutoFlickIfNeeded
                        property int element_id_with_focus: -2
                        onElement_id_with_focusChanged: {
                            if(element_id_with_focus === -1) property_line_edit_country.setFocus(Enums.FocusDir.Left);
                            else if(element_id_with_focus >= address_other_list_model.count) add_button.setFocus(Enums.FocusDir.Right);
                        }

                        ScrollBar.vertical: ScrollBar
                        {
                            parent: address_other_list_view
                            anchors.right: parent.right
                        }

                        Connections {
                            target: address_dialog
                            function onInitProperties() {
                                address_other_list_view.element_id_with_focus = -2;
                            }
                        }

                        function setFocus(dir) {
                            element_id_with_focus = -2;
                            
                            if(address_other_list_model.count <= 0) {
                                if(dir === Enums.FocusDir.Right || dir === Enums.FocusDir.Down) add_button.setFocus(dir);
                                else property_line_edit_country.setFocus(dir);
                            }
                            else {
                                if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) property_column.nextFocus(dir);
                                else if(dir === Enums.FocusDir.Right || dir === Enums.FocusDir.Down) element_id_with_focus = 0;
                                else element_id_with_focus = address_other_list_model.count - 1;
                            }
                        }

                        Component
                        {
                            id: property_other_component

                            PropertyLineEdit
                            {
                                id: property_line_edit_other
                                width: address_other_column.width
                                height: address_other_list_view.height * 0.4
                                description: qsTr("Other ") + (index + 1)
                                value: property_value
                                derivate_value: undefined
                                derivate_mode: true
                                derivate_flag: (value === undefined) ? true : property_derivate_flag
                                border.color: (editing) ? highlightColor : color
                                null_switch_height_percentage: 1.0
                                onNextFocus: function next_focus(dir) {
                                    if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) property_column.nextFocus(dir);
                                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) address_other_list_view.element_id_with_focus = index - 1;
                                    else address_other_list_view.element_id_with_focus = index + 1;
                                }

                                property int element_id_with_focus_wrapper: address_other_list_view.element_id_with_focus
                                onElement_id_with_focus_wrapperChanged: {
                                    if(index === element_id_with_focus_wrapper) setFocus(Enums.FocusDir.Down);
                                }

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

                                    property_line_edit_other.init(derivate_flag);
                                }

                                onNew_value: function new_value(value, derivate_flag, undefined_flag) {
                                    unsaved_changes = true;

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
                        color: backgroundColor2
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
                            onNextFocus: function next_focus(dir) {
                                if(dir === Enums.FocusDir.Save || dir === Enums.FocusDir.Close) property_column.nextFocus(dir);
                                else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) address_other_list_view.setFocus(dir);
                                else property_paragraph_edit_note.setFocus(dir);
                            }

                            onClicked:
                            {
                                unsaved_changes = true;

                                if(address_other_list_view.element_id_with_focus === address_other_list_model.count) {
                                    address_other_list_view.element_id_with_focus++;
                                }

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
                    else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) add_button.setFocus(dir);
                    else parent.nextFocus(dir);
                }

                Connections {
                    target: address_dialog
                    function onInitProperties() {
                        property_paragraph_edit_note.original_value = property_note;
                    }
                }

                onNew_value: function new_value(value, derivate_flag) {
                    unsaved_changes = true;
                    property_note = value;
                }
            }
        }
    }
}