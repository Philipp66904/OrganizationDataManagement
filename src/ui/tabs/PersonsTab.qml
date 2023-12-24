import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import tablemodule 1.0

TemplateTab
{
    id: tab_main
    table_name: "person"
    
    onAdd_button_clicked: function add_button_clicked() {
        person_edit_dialog.pk_id = -1;
        person_edit_dialog.show();
        person_edit_dialog.init_dialog();
    }

    onEdit_button_clicked: function edit_button_clicked(pk) {
        person_edit_dialog.pk_id = pk;
        person_edit_dialog.show();
        person_edit_dialog.init_dialog();
    }

    TableModel
    {
        id: table_model
    }

    function load_data_wrapper() {
        const table_name = "person";
        const res = database.getDataPerson();
        const column_names = res.shift();

        table_model.loadData(table_name, column_names, res);
    }
}