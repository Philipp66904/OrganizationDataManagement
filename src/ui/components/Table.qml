import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Basic

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
    required property string table_name
    required property var pk_id  // set to -1 if new entry  // set to undefined if root table
    required property var parent_id  // set to undefined if it has no parent
    required property double table_view_main_height_factor
    required property double table_cell_rect_height_factor

    property bool sort_reverse: false
    property string sort_column_name: ""
    property string delete_text: qsTr("The specified entry with its derivatives and connections will be deleted.")

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
        if(dir === Enums.FocusDir.Right || dir === Enums.FocusDir.Down) table_view.setFocus(dir);
        else if(dir === Enums.FocusDir.Up) add_button.setFocus(Enums.FocusDir.Up);
        else delete_button.setFocus(Enums.FocusDir.Left);

        focusSet();
    }

    signal nextFocus(dir: int)
    signal focusSet()

    // Connections
    Connections {
        target: database
        function onDataChanged() {
            load_data();  // implement function with specific implementation per tab
            table_view.resetSelection();
        }

        function onDataRowChanged(tb_name, index) {
            if(tb_name === table_name) {
                load_row_data(index);  // implement function with specific implementation per tab
                table_view.resetSelection();
            }
        }

        function onDataRowAdded(tb_name, index) {
            if(tb_name === table_name) {
                load_add_row_data(index);  // implement function with specific implementation per tab
                table_view.resetSelection();
            }
        }

        function onDataRowRemoved(tb_name, index) {
            if(tb_name === table_name) {
                table_model.removeRowData(index, "id");
                table_view.resetSelection();
            }
        }
    }

    Connections {
        target: table_model
        function onUpdateView() {
            table_view.forceLayout();
            table_view.resetSelection();
        }

        function onSortingChanged(column_name, reverse_flag) {
            sort_reverse = reverse_flag;
            sort_column_name = column_name;
            table_view.resetSelection();
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
                    reuseItems: false
                    flickableDirection: Flickable.AutoFlickIfNeeded

                    delegate: Rectangle
                    {
                        implicitWidth: table_view_main.width * 0.22
                        implicitHeight: table_view_main.height * table_cell_rect_height_factor
                        color: (header_rect_mouse_area.containsMouse) ? backgroundColor1 : "transparent"
                        radius: 4

                        required property int index
                        required property string display

                        Text
                        {
                            text: (display !== undefined) ? display : ""
                            height: parent.height - 8
                            width: (sort_indicator.visible) ? parent.width - 8 - sort_indicator.width : parent.width - 8
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            font.pointSize: fontSize_default
                            font.family: fontFamily_default
                            font.bold: true
                            color: textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        Rectangle
                        {
                            id: sort_indicator
                            height: (parent.height * 0.65) - 8
                            width: height
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            color: "transparent"
                            property bool sort_status: (display === sort_column_name) ? true : false
                            visible: !(!sort_status && !header_rect_mouse_area.containsMouse)

                            Image
                            {
                                id: arrow_image
                                visible: false
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                source: "../res/svg/arrow_down.svg"
                            }

                            ColorOverlay
                            {
                                id: arrow_image_overlay
                                anchors.fill: arrow_image
                                source: arrow_image
                                color: {
                                    if(!sort_indicator.sort_status) return backgroundColor3;
                                    else return highlightColor;
                                }
                                visible: parent.visible
                                antialiasing: true
                                rotation: (sort_reverse && sort_indicator.sort_status) ? 180 : 0
                            }
                        }

                        MouseArea
                        {
                            id: header_rect_mouse_area
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                if(sort_indicator.sort_status && !sort_reverse) table_model.sort(display, !sort_reverse, locale_obj);
                                else if(sort_indicator.sort_status && sort_reverse) table_model.sort(table_model.getColumnName(1), false, locale_obj);
                                else table_model.sort(display, false, locale_obj);
                            }
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

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_A && (event.modifiers & Qt.ControlModifier)) {
                            if(add_button.button_enabled && add_button.visible) {
                                add_button.clicked();
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Return) {
                            if(edit_button.button_enabled && edit_button.visible) {
                                edit_button.clicked();
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier)) {
                            if(duplicate_button.button_enabled && duplicate_button.visible) {
                                duplicate_button.clicked();
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Backspace) {
                            if(delete_button.button_enabled && delete_button.visible) {
                                delete_button.clicked();
                                event.accepted = true;
                            }
                        } else if (event.key === Qt.Key_Escape) {
                            table_root.nextFocus(Enums.FocusDir.Close);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Backtab) {
                            table_root.nextFocus(Enums.FocusDir.Left);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                            add_button.setFocus(Enums.FocusDir.Right);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up && table_view_selection_model.selectedIndexes.length > 0 && table_view_selection_model.selectedIndexes[0].row === 0) {
                            table_root.nextFocus(Enums.FocusDir.Up);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down && table_view_selection_model.selectedIndexes.length > 0 && table_view_selection_model.selectedIndexes[0].row === table_model.rowCount() - 1) {
                            add_button.setFocus(Enums.FocusDir.Right);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Home) {
                            table_view.selectionModel.select(table_model.getModelIndex(0, 0), ItemSelectionModel.Rows | ItemSelectionModel.ClearAndSelect);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_End) {
                            table_view.selectionModel.select(table_model.getModelIndex(-1, 0), ItemSelectionModel.Rows | ItemSelectionModel.ClearAndSelect);
                            event.accepted = true;
                        }
                    }

                    function setFocus(dir) {
                        if(table_model.rowCount() <= 0) {
                            if(dir === Enums.FocusDir.Right || dir === Enums.FocusDir.Down) add_button.setFocus(dir);
                            else table_root.nextFocus(dir);
                        } else {
                            forceActiveFocus();

                            if(table_root.selected_pk === undefined || table_root.selected_pk < 0) {
                                if(dir === Enums.FocusDir.Right || dir === Enums.FocusDir.Down) {
                                    table_view.selectionModel.select(table_model.getModelIndex(0, 0), ItemSelectionModel.Rows | ItemSelectionModel.ClearAndSelect);
                                } else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) {
                                    table_view.selectionModel.select(table_model.getModelIndex(-1, 0), ItemSelectionModel.Rows | ItemSelectionModel.ClearAndSelect);
                                } else {
                                    table_root.nextFocus(dir);
                                }
                            }
                        }
                    }

                    Timer
                    {
                        id: reset_selection_timer
                        interval: 10
                        repeat: false

                        onTriggered: {
                            table_view.resetSelectionWorker();
                        }
                    }
                    function resetSelection() {
                        reset_selection_timer.start();
                    }
                    function resetSelectionWorker() {
                        table_root.selected_pk = undefined;
                        table_view.selectionModel.reset();
                        table_view.forceLayout();
                    }

                    ScrollBar.horizontal: ScrollBar
                    {
                        parent: table_view
                        anchors.bottom: parent.bottom
                    }

                    ScrollBar.vertical: ScrollBar
                    {
                        parent: table_view
                        anchors.right: parent.right
                    }

                    Text
                    {
                        id: dummy_txt
                        visible: false
                        width: table_view_main.width * 0.50 - 8
                        height: table_view_main.height * table_cell_rect_height_factor - 8
                        font.pointSize: fontSize_default
                        font.family: fontFamily_default
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
                        dummy_txt.text = longest_text + "      ";
                        return dummy_txt.contentWidth;
                    }

                    Timer
                    {
                        id: position_view_timer
                        interval: 10
                        repeat: false

                        onTriggered: {
                            table_view.positionView();
                        }
                    }
                    function positionView() {
                        table_view.positionViewAtRow(table_view_selection_model.selectedIndexes[0].row, TableView.Contain);
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

                            setCurrentIndex(table_view_selection_model.selectedIndexes[0], ItemSelectionModel.Current);
                            position_view_timer.start();
                        }

                        onCurrentChanged: function (current, previous) {
                            if(current.row !== previous.row) {
                                table_view.selectionModel.select(current, ItemSelectionModel.Rows | ItemSelectionModel.ClearAndSelect);
                            }
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

                        Gradient
                        {
                            id: selected_gradient
                            GradientStop { position: 0.0; color: border.color }
                            GradientStop { position: 0.10; color: cell_rect.color }
                            GradientStop { position: 0.90; color: cell_rect.color }
                            GradientStop { position: 1.0; color: border.color }
                        }
                        gradient: (selected && table_view.focus) ? selected_gradient : null

                        Text
                        {
                            id: cell_text
                            text: (display !== undefined) ? display : qsTr("null")
                            anchors.fill: parent
                            anchors.margins: 4
                            font.pointSize: fontSize_default
                            font.family: fontFamily_default
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
                                table_view.setFocus(Enums.FocusDir.Right);
                                var mp = table_view.mapFromItem(delegate_mouse_area, mouse.x, mouse.y);
                                var cell = table_view.cellAtPos(mp.x, mp.y, false);
                                var min_idx = table_view.model.index(cell.y, 0);
                                table_view.selectionModel.select(min_idx, ItemSelectionModel.Rows | ItemSelectionModel.ClearAndSelect);
                            }

                            onDoubleClicked: function double_clicked(mouse)
                            {
                                table_view.setFocus(Enums.FocusDir.Right);
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
                        else if(dir === Enums.FocusDir.Left || dir === Enums.FocusDir.Up) table_view.setFocus(dir);
                        else table_root.nextFocus(dir);
                    }

                    onClicked:
                    {
                        if(table_root.pk_id !== undefined && table_root.pk_id < 0) {
                            setStatusMessage(qsTr("Save Entry before creating a new derivative"), Enums.StatusMsgLvl.Warn);
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
                        else if(dir === Enums.FocusDir.Up) table_view.setFocus(dir);
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
                        else if(dir === Enums.FocusDir.Up) table_view.setFocus(dir);
                        else table_root.nextFocus(dir);
                    }

                    onClicked: {
                        const pk = table_buttons_main.getPrimaryKey();
                        if (pk < 0) {
                            setStatusMessage(qsTr("Select a row to duplicate"), Enums.StatusMsgLvl.Info);
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
                        else if(dir === Enums.FocusDir.Up) table_view.setFocus(dir);
                        else table_root.nextFocus(dir);
                    }

                    DeleteDialog
                    {
                        id: delete_dialog
                        text: table_root.delete_text
                        function callback_function() {
                            const pk = table_buttons_main.getPrimaryKey();
                            if (pk < 0) {
                                setStatusMessage(qsTr("Select a row to delete"), Enums.StatusMsgLvl.Warn);
                                return;
                            }

                            table_root.delete_button_clicked(pk);
                        }
                    }

                    onClicked: {
                        const pk = table_buttons_main.getPrimaryKey();
                        if (pk < 0) {
                            setStatusMessage(qsTr("Select a row to delete"), Enums.StatusMsgLvl.Warn);
                            return;
                        }

                        delete_dialog.init();
                        delete_dialog.show();
                    }
                }
            }
        }
    }
}