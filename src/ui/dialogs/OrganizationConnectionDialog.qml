import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../components"

ApplicationWindow
{
    id: organization_connection_dialog_window
    title: window_title + " - " + entry_name
    color: backgroundColor
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 150
    width: rootWindow.width * 0.8
    height: rootWindow.height * 0.3

    required property string window_title
    required property var identifier  // -1 if new entry, otherwise connection.id
    property int organization_id: -1
    required property string title_name
    property string entry_name: ""
    
    property string current_person
    property string current_address
    property int current_person_id: -1
    property int current_address_id: -1
    property string error_text: ""

    property bool close_okay: false

    onCurrent_person_idChanged: {
        error_text = check_connection();
    }
    onCurrent_address_idChanged: {
        error_text = check_connection();
    }

    signal save_button_clicked()
    signal delete_button_clicked()
    signal initProperties(connection_id: int, organization_id: int)

    function check_connection() {
        // returns "" if check successfull; error message as string if not
        if (current_person_id < 0 || current_address_id < 0) {
            return qsTr("Specify person and address.");
        }

        const res = database.checkConnection(identifier, current_person_id, current_address_id);

        if(res) {
            return "";
        }
        else {
            return qsTr("Combination already exists.");
        }
    }

    onSave_button_clicked: {
        error_text = database.saveConnection(identifier, organization_id, current_person_id, current_address_id);
        
        if (error_text === "") {
            organization_connection_dialog_window.close();
        }
    }

    onDelete_button_clicked: {
        if(!database.deleteConnection(identifier)) {
            error_text = qsTr("Couldn't delete connection.");
        }
    }

    function init(connection_id, organization_id) {
        button_row.focus = true;
        button_row.forceActiveFocus();
        organization_connection_dialog_window.close_okay = false;
        organization_connection_dialog_window.identifier = connection_id;
        const current_person_address_description = database.getConnection(connection_id);
        if(current_person_address_description[0] !== "") {
            organization_connection_dialog_window.entry_name = current_person_address_description[0];
        }
        else {
            organization_connection_dialog_window.entry_name = qsTr("New Connection");
        }
        organization_connection_dialog_window.current_person = current_person_address_description[1];
        organization_connection_dialog_window.current_address = current_person_address_description[2];
        organization_connection_dialog_window.organization_id = organization_id;

        organization_connection_dialog_window.initProperties(connection_id, organization_id);
    }

    // Closing handler
    FileCloseDialog 
    {
        id: close_dialog
        function callback_function() { organization_connection_dialog_window.close_okay = true; organization_connection_dialog_window.close(); }
    }
    onClosing: (close) => {
        close.accepted = false;

        if(!organization_connection_dialog_window.close_okay) {
            close_dialog.show();
        }

        if(organization_connection_dialog_window.close_okay) close.accepted = true;
    }

    Column
    {
        id: main_column
        anchors.fill: parent
        spacing: 4
        property int row_count: 4

        property int title_rect_height: (height - (row_count * spacing)) * 0.20
        property int selection_column_height: (height - (row_count * spacing)) * 0.65
        property int button_row_height: (height - (row_count * spacing)) * 0.15

        // Column heights
        property int combo_selection_person_height: (main_column.selection_column_height - (row_count * spacing)) * 0.33
        property int combo_selection_address_height: (main_column.selection_column_height - (row_count * spacing)) * 0.33
        property int err_text_rect_height: (main_column.selection_column_height - (row_count * spacing)) * 0.33

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
                    text: organization_connection_dialog_window.title_name
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
                    text: organization_connection_dialog_window.entry_name
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
            spacing: 8

            ComboSelection
            {
                id: combo_selection_person
                width: parent.width - 8
                height: main_column.combo_selection_person_height
                anchors.horizontalCenter: parent.horizontalCenter
                description_text: qsTr("Person")

                onSelected_indexChanged: {
                    organization_connection_dialog_window.current_person_id = combo_selection_person.selected_index;
                }

                Connections {
                    target: organization_connection_dialog_window
                    function onInitProperties(connection_id, organization_id) {
                        const person_data = database.getPersonConnection(connection_id);
                        combo_selection_person.load_data(person_data);
                        organization_connection_dialog_window.current_person_id = combo_selection_person.selected_index;
                    }
                }
            }

            ComboSelection
            {
                id: combo_selection_address
                width: parent.width - 8
                height: main_column.combo_selection_address_height
                anchors.horizontalCenter: parent.horizontalCenter
                description_text: qsTr("Address")

                onSelected_indexChanged: {
                    organization_connection_dialog_window.current_address_id = combo_selection_address.selected_index;
                }

                Connections {
                    target: organization_connection_dialog_window
                    function onInitProperties(connection_id, organization_id) {
                        const address_data = database.getAddressConnection(connection_id);
                        combo_selection_address.load_data(address_data);
                        organization_connection_dialog_window.current_address_id = combo_selection_address.selected_index;
                    }
                }
            }

            ErrorRect
            {
                id: err_text_rect
                width: parent.width - 8
                height: main_column.err_text_rect_height
                anchors.horizontalCenter: parent.horizontalCenter
                visible: (error_text !== "") ? true : false
                error_text: organization_connection_dialog_window.error_text
            }

            NotificationRect
            {
                id: notification_text_rect
                width: err_text_rect.width
                height: err_text_rect.height
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !err_text_rect.visible
                notification_text: qsTr("Combination available.")
            }
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

            focus: true
            Keys.onReturnPressed: save_button.clicked()
            Keys.onEscapePressed: abort_button.clicked()

            BasicButton
            {
                id: save_button
                width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                height: parent.height
                hover_color: highlight_color
                text: qsTr("Save")
                button_enabled: (organization_connection_dialog_window.error_text === "") ? true : false
                selected: parent.focus

                onClicked:
                {
                    organization_connection_dialog_window.close_okay = true;
                    organization_connection_dialog_window.save_button_clicked();
                }
            }

            BasicButton
            {
                id: delete_button
                width: (parent.width - ((button_row.button_count - 1) * parent.spacing)) / button_row.button_count
                height: parent.height
                highlight_color: "#ff0000"
                text: qsTr("Delete")
                button_enabled: (organization_connection_dialog_window.identifier !== -1) ? true : false

                DeleteDialog
                {
                    id: delete_dialog
                    function callback_function() {
                        organization_connection_dialog_window.delete_button_clicked();
                        organization_connection_dialog_window.close_okay = true;
                        organization_connection_dialog_window.close();
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

                onClicked:
                {
                    organization_connection_dialog_window.close();
                }
            }
        }
    }
}