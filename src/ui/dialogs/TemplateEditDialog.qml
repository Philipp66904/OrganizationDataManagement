import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"

import tablemodule 1.0

ApplicationWindow
{
    id: edit_dialog_window
    title: window_title + ": " + entry_name
    color: backgroundColor
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 90
    width: rootWindow.width * 0.8
    height: rootWindow.height * 0.8

    required property string window_title
    required property var identifier
    required property var parent_identifier
    required property string title_name
    required property string entry_name
    required property string table_name

    function init_dialog() {}  // implement this function

    function init() {  // call this function in your init_dialog override
        console.log("init");
        derivate_table.load_data();
    }

    signal add_button_clicked()
    signal edit_button_clicked(selected_primary_key: int)
    signal duplicate_button_clicked(selected_primary_key: int)
    signal delete_button_clicked(selected_primary_key: int)

    Column
    {
        id: main_column
        anchors.fill: parent
        spacing: 4
        property int row_count: 9

        property int title_rect_height: (height - (row_count * spacing)) * 0.07
        property int table_height: (height - (row_count * spacing)) * 0.3

        Component
        {
            id: separator_component

            Rectangle
            {
                width: main_column.width
                height: 1
                color: backgroundColor1
            }
        }

        Rectangle
        {
            id: title_rect
            height: main_column.title_rect_height
            width: parent.width
            color: backgroundColor1

            Row
            {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8

                Text
                {
                    id: title_text
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height
                    text: edit_dialog_window.title_name
                    font.pointSize: textSizeBig
                    color: textColor
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font.bold: true
                }

                Text
                {
                    id: entry_name_text
                    width: (parent.width - parent.spacing) / 2
                    height: parent.height
                    text: edit_dialog_window.entry_name
                    font.pointSize: textSizeBig
                    color: backgroundColor3
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        Table
        {
            id: derivate_table
            height: main_column.table_height
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            table_view_main_height_factor: 0.8
            table_cell_rect_height_factor: 0.25
            pk_id: identifier
            parent_id: parent_identifier

            TableModel
            {
                id: table_model
            }

            function load_data() {
                const res = database.getDataDerivates(edit_dialog_window.identifier, "parent_id", edit_dialog_window.table_name);
                const column_names = res.shift();

                table_model.loadData(edit_dialog_window.table_name, column_names, res);
            }

            onAdd_button_clicked: function add_button_clicked() {
                edit_dialog_window.add_button_clicked();
            }

            onEdit_button_clicked: function edit_button_clicked(pk) {
                edit_dialog_window.edit_button_clicked(pk);
            }

            onDuplicate_button_clicked: function duplicate_button_clicked(pk) {
                edit_dialog_window.duplicate_button_clicked(pk);
            }

            onDelete_button_clicked: function delete_button_clicked(pk) {
                edit_dialog_window.delete_button_clicked(pk);
            }
        }

        Loader { sourceComponent: separator_component; }
    }
}