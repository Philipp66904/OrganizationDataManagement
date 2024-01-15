import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../types"

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

    required property var search_res

    TableModel
    {
        id: table_model
    }

    function load_data() {
        let res = search_res.slice();
        let column_names = res.shift();
        if(res === undefined || res.length <= 0) res = [];
        if(column_names === undefined || column_names.length <= 0) column_names = [];
        column_names = database.translateColumnNames(column_names);

        table_model.loadData(result_table.table_name, column_names, res);
    }

    function load_row_data(index) {
        //console.log("SearchResultTable::load_row_data:", index);
    }
    function load_add_row_data(index) {
        //console.log("SearchResultTable::load_add_row_data:", index);
    }

    onDelete_button_clicked: function delete_button_clicked(pk) {
        const msg = setStatusMessage(database.deleteEntry(pk, "id", result_table.table_name), Enums.StatusMsgLvl.Err);
        if(msg !== "") return;
    }
}