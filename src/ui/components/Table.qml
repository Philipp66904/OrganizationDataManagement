import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import tablemodule 1.0

import "../dialogs"
import "../types"

Rectangle
{
    id: table_root
    color: backgroundColor2
    radius: 4

    property var selected_pk: undefined
    property bool show_duplicate_button: true
    property bool show_add_button: true
    required property var pk_id  // set to -1 if new entry  // set to undefined if root table
    required property var parent_id  // set to undefined if it has no parent
    required property double table_view_main_height_factor
    required property double table_cell_rect_height_factor

    signal add_button_clicked()
    signal edit_button_clicked(selected_primary_key: int)
    signal duplicate_button_clicked(selected_primary_key: int)
    signal delete_button_clicked(selected_primary_key: int)

    function editEntry()
    {
        const pk = table_buttons_main.getPrimaryKey();
        if (pk < 0) {
            return;
        }

        table_root.edit_button_clicked(pk);
    }

    function setFocus(dir) {
        if(dir === Enums.FocusDir.Right || dir === Enums.FocusDir.Down) add_button.setFocus(Enums.FocusDir.Right);
        else delete_button.setFocus(Enums.FocusDir.Left);
    }

    signal nextFocus(dir: int)

    // Connections
    Connections {
        target: database
        function onDataChanged() {
            load_data();  // implement function with specific implementation per tab
            table_root.selected_pk = undefined;
        }
    }

    Connections {
        target: table_model
        function onUpdateView() {
            table_view.forceLayout();
            table_root.selected_pk = undefined;
        }
    }

    Column
    {
        id: main_column
        anchors.fill: parent
        spacing: 4
        anchors.topMargin: margins
        anchors.bottomMargin: margins
        property int margins: 4
        
        Rectangle
        {
            id: table_view_main
            width: parent.width - (main_column.margins * 2)
            height: (parent.height * table_view_main_height_factor) - main_column.spacing
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Column
            {
                anchors.fill: parent
                spacing: 2

                HorizontalHeaderView
                {
                    id: table_view_header
                    width: table_view.width
                    height: table_view_main.height * table_cell_rect_height_factor
                    anchors.left: parent.left
                    syncView: table_view
                    clip: true
                    resizableColumns: false
                    flickableDirection: Flickable.AutoFlickIfNeeded

                    delegate: Rectangle
                    {
                        implicitWidth: table_view_main.width * 0.22
                        implicitHeight: table_view_main.height * table_cell_rect_height_factor
                        color: "transparent"
                        radius: 4

                        Text
                        {
                            text: (display !== undefined) ? display : ""
                            anchors.fill: parent
                            anchors.margins: 4
                            font.pointSize: textSize
                            font.bold: true
                            color: textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }

                Rectangle
                {
                    id: table_view_separator
                    width: parent.width
                    height: 1
                    anchors.left: table_view_header.left
                    color: backgroundColor3
                }

                TableView
                {
                    id: table_view
                    width: parent.width
                    height: parent.height - table_view_header.height - separator.height - (parent.spacing * 2)
                    rowSpacing: 4
                    columnSpacing: 4
                    clip: true
                    anchors.left: parent.left
                    resizableColumns: false
                    columnWidthProvider: get_column_width
                    selectionMode: TableView.SingleSelection
                    flickableDirection: Flickable.AutoFlickIfNeeded

                    onLayoutChanged: {
                        table_root.selected_pk = undefined;
                        table_view_selection_model.clear();
                    }

                    Text
                    {
                        id: dummy_txt
                        visible: false
                        width: table_view_main.width * 0.50 - 8
                        height: table_view_main.height * table_cell_rect_height_factor - 8
                        font.pointSize: textSize
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    function get_column_width(column) {
                        // Check if column is used as a primary key in the database -> these columns are hidden
                        const column_name = table_model.headerData(column, undefined, undefined);
                        if (database.getPrimaryKeyColumnNames(table_model.getTableName()).includes(column_name)) {
                            return 0;
                        }

                        let longest_text = table_model.getLongestText(column);
                        if(longest_text.length <= 0) longest_text = qsTr("null");
                        dummy_txt.text = longest_text + "    ";
                        return dummy_txt.contentWidth;
                    }

                    model: table_model
                    selectionModel: ItemSelectionModel
                    {
                        id: table_view_selection_model
                        model: table_view.model
                        onSelectionChanged: function (selected, deselected) {
                            if(selected.length === 0) {
                                table_root.selected_pk = undefined;
                                return;
                            }

                            const row = table_view_selection_model.selectedIndexes[0].row;
                            const column_index = table_model.getColumnIndex("id");
                            const pk_type = table_model.getValueType(column_index, row);

                            let pk = undefined;
                            if(pk_type === "str") pk = table_model.getValueStr(column_index, row);
                            else if(pk_type === "int") pk = table_model.getValueInt(column_index, row);
                            else if(pk_type === "float") pk = table_model.getValueFloat(column_index, row);

                            table_root.selected_pk = pk;
                        }
                    }

                    delegate: Rectangle
                    {
                        id: cell_rect
                        implicitWidth: table_view_main.width * 0.22
                        implicitHeight: table_view_main.height * table_cell_rect_height_factor
                        color: (delegate_mouse_area.containsMouse || selected) ? backgroundColor1 : "transparent"
                        border.color: (selected) ? backgroundColor3 : color
                        border.width: 1
                        radius: 4
                        required property bool selected
                        required property bool current

                        Text
                        {
                            id: cell_text
                            text: (display !== undefined) ? display : qsTr("null")
                            anchors.fill: parent
                            anchors.margins: 4
                            font.pointSize: textSize
                            color: (display !== undefined) ? textColor : textColor1
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            font.italic: (display === undefined) ? true : false
                            font.bold: (selected) ? true : false
                        }

                        MouseArea
                        {
                            id: delegate_mouse_area
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: function (mouse)  {
                                var mp = table_view.mapFromItem(delegate_mouse_area, mouse.x, mouse.y);
                                var cell = table_view.cellAtPos(mp.x, mp.y, false);
                                var min_idx = table_view.model.index(cell.y, 0);
                                table_view.selectionModel.select(min_idx, ItemSelectionModel.Rows | ItemSelectionModel.ClearAndSelect);
                            }

                            onDoubleClicked: function double_clicked(mouse)
                            {
                                delegate_mouse_area.clicked(mouse);
                                table_root.editEntry();
                            }
                        }
                    }
                }
            }
            SelectionRectangle
            {
                id: table_view_selection_rect
                target: table_view
            }
        }

        Rectangle
        {
            id: separator
            width: parent.width
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            color: backgroundColor3
        }

        Rectangle
        {
            id: table_buttons_main
            width: table_view_main.width
            height: parent.height - table_view_main.height - separator.height - (main_column.spacing * 2)
            anchors.horizontalCenter: parent.horizontalCenter
            color: backgroundColor1
            radius: 8

            function getPrimaryKey() {
                let pk = table_root.selected_pk;
                if(pk === undefined) pk = -1;

                return pk;
            }

            Row
            {
                id: table_button_row
                anchors.fill: parent
                spacing: 8
                property int button_count: {
                    let res = 2;
                    if(show_duplicate_button) res += 1;
                    if(show_add_button) res += 1;
                    return res;
                }

                BasicButton
                {
                    id: add_button
                    width: (parent.width - ((table_button_row.button_count - 1) * parent.spacing)) / table_button_row.button_count
                    height: parent.height
                    visible: show_add_button
                    hover_color: highlight_color
                    text: qsTr("Add")
                    button_enabled: (table_root.pk_id !== undefined && table_root.pk_id < 0) ? false : true
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close) {
                            table_root.nextFocus(dir);
                            return;
                        }

                        if(dir === Enums.FocusDir.Right) edit_button.setFocus(dir);
                        else table_root.nextFocus(dir);
                    }

                    onClicked:
                    {
                        if(table_root.pk_id !== undefined && table_root.pk_id < 0) {
                            error_message = qsTr("Save Entry before creating a new derivate");
                            return;
                        }

                        table_root.add_button_clicked()
                    }
                }

                BasicButton
                {
                    id: edit_button
                    width: add_button.width
                    height: add_button.height
                    hover_color: textColor
                    text: qsTr("Edit")
                    button_enabled: (table_root.selected_pk !== undefined) ? true : false
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close) {
                            table_root.nextFocus(dir);
                            return;
                        }

                        if(dir === Enums.FocusDir.Right) duplicate_button.setFocus(dir);
                        else if(dir === Enums.FocusDir.Left) add_button.setFocus(dir);
                        else table_root.nextFocus(dir);
                    }

                    onClicked: {
                        table_root.editEntry();
                    }
                }

                BasicButton
                {
                    id: duplicate_button
                    visible: show_duplicate_button
                    width: add_button.width
                    height: add_button.height
                    hover_color: textColor
                    text: qsTr("Duplicate")
                    button_enabled: (table_root.selected_pk !== undefined) ? true : false
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close) {
                            table_root.nextFocus(dir);
                            return;
                        }

                        if(dir === Enums.FocusDir.Left) edit_button.setFocus(dir);
                        else if(dir === Enums.FocusDir.Right) delete_button.setFocus(dir);
                        else table_root.nextFocus(dir);
                    }

                    onClicked: {
                        const pk = table_buttons_main.getPrimaryKey();
                        if (pk < 0) {
                            error_message = qsTr("Select a row to duplicate");
                            return;
                        }

                        table_root.duplicate_button_clicked(pk);
                    }
                }

                BasicButton
                {
                    id: delete_button
                    width: add_button.width
                    height: add_button.height
                    highlight_color: backgroundColorError
                    text: qsTr("Delete")
                    button_enabled: (table_root.selected_pk !== undefined) ? true : false
                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close) {
                            table_root.nextFocus(dir);
                            return;
                        }

                        if(dir === Enums.FocusDir.Left) duplicate_button.setFocus(dir);
                        else table_root.nextFocus(dir);
                    }

                    DeleteDialog
                    {
                        id: delete_dialog
                        function callback_function() {
                            const pk = table_buttons_main.getPrimaryKey();
                            if (pk < 0) {
                                error_message = qsTr("Select a row to delete");
                                return;
                            }

                            table_root.delete_button_clicked(pk);
                        }
                    }

                    onClicked: {
                        const pk = table_buttons_main.getPrimaryKey();
                        if (pk < 0) {
                            error_message = qsTr("Select a row to delete");
                            return;
                        }

                        delete_dialog.show();
                    }
                }
            }
        }
    }
}