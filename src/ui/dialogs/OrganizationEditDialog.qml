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

    function init_dialog() {
        // call this function after .show() called on the ApplicationWindow
        let val = -1;
        if(pk_id >= 0) val = database.getValueInt_byPk(pk_id, "id", "parent_id", organization_dialog.table_name);
        organization_dialog.parent_id = val;

        let entry_name_tmp = "New Entry";
        if(pk_id >= 0) entry_name_tmp = database.getName_byPk(pk_id, "id", organization_dialog.table_name)
        organization_dialog.entry_name = entry_name_tmp;

        init();
    }
}