import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

Rectangle
{
    id: button_selection
    color: (button_selection_focus_scope.focus) ? backgroundColor2 : backgroundColor
    border.color: (button_selection_focus_scope.focus) ? highlightColor : backgroundColor3
    border.width: 1
    radius: 4

    required property string table_name
    required property string description_text

    signal updateListModel()

    ListModel
    {
        id: button_selection_list_model
    }

    function getListModel() {
        const res = [];
        for(let i = 0; i < button_selection_list_model.count; i++) {
            res.push({"column_name": button_selection_list_model.get(i).column_name, "button_checked": button_selection_list_model.get(i).button_checked});
        }

        return res;
    }

    function init() {
        button_selection_list_model.clear();

        const col_names_description = database.getNonPrimaryKeyNonForeignKeyColumnNames("description");
        for(let col_name of col_names_description) {
            button_selection_list_model.append({"column_name": col_name, "button_checked": true});
        }

        const col_names = database.getNonPrimaryKeyNonForeignKeyColumnNames(table_name);
        for(let col_name of col_names) {
            button_selection_list_model.append({"column_name": col_name, "button_checked": true});
        }
    }

    FocusScope
    {
        id: button_selection_focus_scope
        anchors.fill: parent

        Column
        {
            id: button_selection_column
            anchors.fill: parent
            anchors.margins: 4
            spacing: 8
            property int row_count: 2

            Text
            {
                id: button_selection_description
                text: description_text
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_count
                width: parent.width
                font.pointSize: textSize
                color: backgroundColor3
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            ListView
            {
                id: button_selection_list_view
                width: parent.width
                height: (parent.height - ((parent.row_count - 1) * parent.spacing)) / parent.row_count
                clip: true
                model: button_selection_list_model
                spacing: 8
                orientation: ListView.Horizontal
                interactive: (contentWidth <= width) ? false : true

                property int button_count: Math.min(Math.round(width / 125), button_selection_list_model.count)

                delegate: BasicCheckbox
                {
                    id: checkbox
                    text: column_name
                    height: button_selection_list_view.height
                    width: (button_selection_column.width - ((button_selection_list_view.button_count - 1) * button_selection_list_view.spacing)) / button_selection_list_view.button_count
                    checked: button_checked

                    onCheckedChanged: {
                        button_selection_list_model.set(index, {"button_checked": checkbox.checked});
                        updateListModel();
                    }
                }

                ScrollBar.horizontal: ScrollBar
                {
                    parent: button_selection_list_view
                    anchors.bottom: parent.bottom
                }
            }
        }
    }
}