import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../types"

import tablemodule 1.0

TemplateTab
{
    id: tab_main
    table_name: "organization"
    
    onAdd_button_clicked: function add_button_clicked() {
        organization_edit_dialog.pk_id = -1;
        organization_edit_dialog.parent_id = undefined;
        organization_edit_dialog.show();
        organization_edit_dialog.init_dialog();
    }

    onEdit_button_clicked: function edit_button_clicked(pk) {
        organization_edit_dialog.pk_id = pk;
        organization_edit_dialog.parent_id = undefined;
        organization_edit_dialog.show();
        organization_edit_dialog.init_dialog();
    }

    onDuplicate_button_clicked: function duplicate_button_clicked(pk) {
        const msg = setStatusMessage(database.duplicateEntry(pk, "id", tab_main.table_name), Enums.StatusMsgLvl.Err);
        if(msg !== "") return;
    }

    TableModel
    {
        id: table_model
    }

    function load_data_wrapper() {
        const table_name = "organization";
        const res = database.getDataOrganization();
        const column_names = database.translateColumnNames(res.shift());

        table_model.loadData(table_name, column_names, res);
    }
}