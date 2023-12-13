import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import tablemodule 1.0

TemplateTab
{
    id: tab_main
    
    TableModel
    {
        id: table_model
    }

    function load_data() {
        const res = database.getDataOrganization();
        const column_names = res.shift();

        table_model.loadData(column_names, res);
    }
}