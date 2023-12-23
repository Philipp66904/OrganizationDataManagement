import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import tablemodule 1.0

TemplateTab
{
    id: tab_main
    table_name: "organization"
    
    onAdd_button_clicked: function add_button_clicked() {
        organization_edit_dialog.pk_id = -1;
        organization_edit_dialog.show();
        organization_edit_dialog.init_dialog();
    }

    onEdit_button_clicked: function edit_button_clicked(pk) {
        organization_edit_dialog.pk_id = pk;
        organization_edit_dialog.show();
        organization_edit_dialog.init_dialog();
    }

    onDelete_button_clicked: function delete_button_clicked(pk) {
        console.log("delete:", pk)
    }

    TableModel
    {
        id: table_model
    }

    function load_data_wrapper() {
        const table_name = "organization";
        const res = database.getDataOrganization();
        const column_names = res.shift();

        table_model.loadData(table_name, column_names, res);
    }
}