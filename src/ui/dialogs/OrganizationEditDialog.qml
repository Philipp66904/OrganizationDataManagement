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
    parent_identifier: parent_id
    entry_name: "New Entry"
    window_title: "Add / Edit Organization"
    title_name: "Organization"
    table_name: "organization"
    property var parent_id: undefined
    property string qml_file_name: "OrganizationEditDialog.qml"

    onClosing: max_derivate_windows++;

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        max_derivate_windows--;

        let entry_name_tmp = "New Entry";
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", organization_dialog.table_name)
        organization_dialog.entry_name = entry_name_tmp;

        init();
    }

    onAdd_button_clicked: function add_button_clicked() {
        create_derivate_window(-1, qml_file_name);
    }

    onEdit_button_clicked: function edit_button_clicked(pk) {
        create_derivate_window(pk, qml_file_name);
    }

    onDuplicate_button_clicked: function duplicate_button_clicked(pk) {
        console.log("duplicate derivate:", pk)
        // TODO implement
    }

    onDelete_button_clicked: function delete_button_clicked(pk) {
        console.log("delete derivate:", pk)
        // TODO implement
    }
}