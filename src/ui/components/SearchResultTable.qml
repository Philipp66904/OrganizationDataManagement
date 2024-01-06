import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import tablemodule 1.0

Table
{
    id: result_table
    table_view_main_height_factor: 0.87
    table_cell_rect_height_factor: 0.16
    pk_id: -1
    parent_id: -1
    show_duplicate_button: false
    show_add_button: false

    required property string table_name
    required property var search_res

    TableModel
    {
        id: table_model
    }

    function load_data() {
        let res = search_res;
        let column_names = res.shift();
        if(res === undefined || res.length <= 0) res = [];
        if(column_names === undefined || column_names.length <= 0) column_names = [];

        table_model.loadData(result_table.table_name, column_names, res);
    }

    onDelete_button_clicked: function delete_button_clicked(pk) {
        error_message = database.deleteEntry(pk, "id", result_table.table_name);
        if(error_message !== "") return;
    }
}