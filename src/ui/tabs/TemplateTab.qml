import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"

Rectangle
{
    id: template_root

    color: "transparent"

    signal add_button_clicked()
    signal edit_button_clicked(selected_primary_key: int)
    signal duplicate_button_clicked(selected_primary_key: int)
    signal delete_button_clicked(selected_primary_key: int)

    Text
    {
        id: template_text
        text: qsTr("Template")
    }

    Table
    {
        anchors.fill: parent
        table_view_main_height_factor: 0.94
        table_cell_rect_height_factor: 0.07

        onAdd_button_clicked: function add_button_handler() {
            template_root.add_button_clicked()
        }
        onEdit_button_clicked: function edit_button_handler(selected_primary_key) {
            template_root.edit_button_clicked(selected_primary_key)
        }
        onDuplicate_button_clicked: function duplicate_button_handler(selected_primary_key) {
            template_root.duplicate_button_clicked(selected_primary_key)
        }
        onDelete_button_clicked: function delete_button_handler(selected_primary_key) {
            template_root.delete_button_clicked(selected_primary_key)
        }
    }
}