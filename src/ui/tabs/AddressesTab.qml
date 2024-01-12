import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import tablemodule 1.0

TemplateTab
{
    id: tab_main
    table_name: "address"

    onAdd_button_clicked: function add_button_clicked() {
        address_edit_dialog.pk_id = -1;
        address_edit_dialog.parent_id = undefined;
        address_edit_dialog.show();
        address_edit_dialog.init_dialog();
    }

    onEdit_button_clicked: function edit_button_clicked(pk) {
        address_edit_dialog.pk_id = pk;
        address_edit_dialog.parent_id = undefined;
        address_edit_dialog.show();
        address_edit_dialog.init_dialog();
    }

    onDuplicate_button_clicked: function duplicate_button_clicked(pk) {
        const msg = setStatusMessage(database.duplicateEntry(pk, "id", tab_main.table_name, "address_id", "address_other"), Enums.StatusMsgLvl.Err);
        if(msg !== "") return;
    }
    
    TableModel
    {
        id: table_model
    }

    function load_data_wrapper() {
        const table_name = "address";
        const res = database.getDataAddress();
        const column_names = res.shift();

        table_model.loadData(table_name, column_names, res);
    }
}