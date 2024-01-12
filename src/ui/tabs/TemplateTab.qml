import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"
import "../types"

Rectangle
{
    id: template_root
    color: "transparent"

    required property string table_name

    signal add_button_clicked()
    signal edit_button_clicked(selected_primary_key: int)
    signal duplicate_button_clicked(selected_primary_key: int)
    signal delete_button_clicked(selected_primary_key: int)

    function setFocus(dir) {
        main_table.setFocus(dir);
    }

    signal nextFocus(dir: int)

    Table
    {
        id: main_table
        anchors.fill: parent
        pk_id: undefined
        parent_id: undefined
        table_view_main_height_factor: 0.94
        table_cell_rect_height_factor: 0.07
        
        Component.onCompleted: setFocus(Enums.FocusDir.Right)

        onNextFocus: function next_focus(dir) {
            parent.nextFocus(dir);
        }

        function load_data() {
            load_data_wrapper();  // implement function with specific implementation per tab
        }

        onAdd_button_clicked: function add_button_handler() {
            template_root.add_button_clicked();
        }
        onEdit_button_clicked: function edit_button_handler(selected_primary_key) {
            template_root.edit_button_clicked(selected_primary_key);
        }
        onDuplicate_button_clicked: function duplicate_button_handler(selected_primary_key) {
            template_root.duplicate_button_clicked(selected_primary_key);
        }
        onDelete_button_clicked: function delete_button_handler(selected_primary_key) {
            status_message = database.deleteEntry(selected_primary_key, "id", table_name);
            if(status_message !== "") return;

            template_root.delete_button_clicked(selected_primary_key);
        }
    }
}