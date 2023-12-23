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