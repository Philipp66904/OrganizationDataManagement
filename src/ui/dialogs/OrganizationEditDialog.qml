import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

TemplateEditDialog
{
    id: organization_dialog
    required property int pk_id
    identifier: pk_id
    parent_identifier: -1
    entry_name: "New Entry"
    window_title: "Add / Edit Organization"
    title_name: "Organization"
    table_name: "organization"
    property int parent_id: -1

    onClosing: max_derivate_windows++;

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        max_derivate_windows--;

        let val = -1;
        if(pk_id >= 0) val = database.getValueInt_byPk(pk_id, "id", "parent_id", organization_dialog.table_name);
        organization_dialog.parent_id = val;

        let entry_name_tmp = "New Entry";
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", organization_dialog.table_name)
        organization_dialog.entry_name = entry_name_tmp;

        init();
    }

    function create_derivate_window(pk) {
        if(max_derivate_windows <= 0) {
            error_message = qsTr("Max amount of derivate windows reached");
            return;
        }

        var component = Qt.createComponent("OrganizationEditDialog.qml");
        var new_dialog_window = component.createObject(organization_dialog, { pk_id: pk });

        if (new_dialog_window == null) {
            error_message = qsTr("Error in creating a new window");
        }
        else {
            new_dialog_window.show();
            new_dialog_window.init_dialog();
        }
    }

    onAdd_button_clicked: function add_button_clicked() {
        create_derivate_window(-1);
    }

    onEdit_button_clicked: function edit_button_clicked(pk) {
        create_derivate_window(pk);
    }

    onDuplicate_button_clicked: function duplicate_button_clicked(pk) {
        console.log("duplicate derivate:", pk)
    }

    onDelete_button_clicked: function delete_button_clicked(pk) {
        console.log("delete derivate:", pk)
    }
}