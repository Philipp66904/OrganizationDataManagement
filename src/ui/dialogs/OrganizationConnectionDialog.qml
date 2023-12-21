import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../components"

ApplicationWindow
{
    id: edit_dialog_window
    title: window_title + " - " + entry_name
    color: backgroundColor
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 90
    width: rootWindow.width * 0.8
    height: rootWindow.height * 0.8

    required property string window_title
    required property var identifier  // -1 if new entry, otherwise connection.id
    required property string title_name
    property string entry_name: qsTr("New Connection")
    
    property string current_person
    property string current_address

    signal save_button_clicked()
    signal delete_button_clicked()

    function init(connection_id) {
        edit_dialog_window.identifier = connection_id;
        const current_person_address_description = database.getConnection(connection_id);
        edit_dialog_window.current_person = current_person_address_description[0];
        edit_dialog_window.current_address = current_person_address_description[1];

        const res = database.getAvailPersonConnection(connection_id);
        console.log("res:", res);
        const res2 = database.getAvailAddressConnection(connection_id);
        console.log("res2:", res2)
        // TODO implement ComboBoxes with data
        // TODO Save identifier for currently selected person and address
        // TODO Make sure to only allow complete connections
    }

    Column
    {
        id: main_column
        anchors.fill: parent
        spacing: 4
        property int row_count: 4

        property int title_rect_height: (height - (row_count * spacing)) * 0.07
        property int selection_column_height: (height - (row_count * spacing)) * 0.87
        property int button_row_height: (height - (row_count * spacing)) * 0.06

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

        Column
        {
            id: selection_column
            height: main_column.selection_column_height
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Loader { sourceComponent: separator_component; }

        Row
        {
            id: button_row
            width: parent.width - 8
            height: main_column.button_row_height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            property int button_count: 3

            BasicButton
            {
                id: save_button
                width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                height: parent.height
                hover_color: highlight_color
                text: qsTr("Save")
                button_enabled: true

                onClicked:
                {
                    edit_dialog_window.save_button_clicked();
                    edit_dialog_window.close();
                }
            }

            BasicButton
            {
                id: delete_button
                width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                height: parent.height
                highlight_color: "#ff0000"
                text: qsTr("Delete")
                button_enabled: (edit_dialog_window.identifier !== -1) ? true : false //true

                DeleteDialog
                {
                    id: delete_dialog
                    function callback_function() {
                        edit_dialog_window.delete_button_clicked();
                        edit_dialog_window.close();
                    }
                }

                onClicked:
                {
                    delete_dialog.show();
                }
            }

            BasicButton
            {
                id: abort_button
                width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                height: parent.height
                hover_color: textColor
                text: qsTr("Abort")
                button_enabled: true

                FileCloseDialog 
                {
                    id: abort_dialog
                    function callback_function() { edit_dialog_window.close(); }
                }

                onClicked:
                {
                    abort_dialog.show();
                }
            }
        }
    }
}