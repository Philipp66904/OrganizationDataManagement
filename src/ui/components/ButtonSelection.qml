import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../types"

Rectangle
{
    id: button_selection
    color: "transparent"
    border.color: backgroundColor2
    border.width: 1
    radius: 4

    required property string table_name
    required property string description_text
    property int element_id_with_focus: -2
    onElement_id_with_focusChanged: {
        if(element_id_with_focus === -1) nextFocus(Enums.FocusDir.Up);
        else if(element_id_with_focus >= button_selection_list_model.count) nextFocus(Enums.FocusDir.Down);
    }

    signal updateListModel()
    signal nextFocus(dir: int)

    function setFocus(dir) {
        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) nextFocus(dir);
        else if(button_selection_list_model.count <= 0) nextFocus(dir);
        else if(dir === Enums.FocusDir.Down || Enums.FocusDir.Right) element_id_with_focus = 0;
        else element_id_with_focus = button_selection_list_model.count - 1;
    }

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

    function setButtonState(state) {
        /*
         * Sets the button state of all buttons to a specific value.
         * If state === 0 or anything not listed here, deselect all buttons.
         * If state === 1, select all buttons.
         * If state === -1, invert current selection.
         */

        for(let i = 0; i < button_selection_list_model.count; i++) {
            let new_state = false;

            if(state === 0) new_state = false;
            else if(state === 1) new_state = true;
            else if(state === -1) {
                new_state = !button_selection_list_model.get(i).button_checked;
            }

            button_selection_list_model.setProperty(i, "button_checked", new_state);
        }

        updateListModel();
    }

    function init() {
        button_selection_list_model.clear();

        const col_names_description = database.getNonPrimaryKeyNonForeignKeyColumnNames("description");
        const col_names_description_translated = database.translateColumnNames(database.getNonPrimaryKeyNonForeignKeyColumnNames("description"));
        let i = 0;
        for(let col_name of col_names_description) {
            const col_trans = col_names_description_translated[i];
            button_selection_list_model.append({"column_name": col_name, "button_checked": true, "column_name_translation": col_trans});
            i++;
        }
        
        const col_names = database.getNonPrimaryKeyNonForeignKeyColumnNames(table_name);
        const col_names_translation = database.translateColumnNames(database.getNonPrimaryKeyNonForeignKeyColumnNames(table_name));
        i = 0;
        for(let col_name of col_names) {
            const col_trans = col_names_translation[i];
            button_selection_list_model.append({"column_name": col_name, "button_checked": true, "column_name_translation": col_trans});
            i++;
        }

        element_id_with_focus = -2;
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
                color: textColor1
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
                    text: column_name_translation
                    height: button_selection_list_view.height
                    width: (button_selection_column.width - ((button_selection_list_view.button_count - 1) * button_selection_list_view.spacing)) / button_selection_list_view.button_count
                    checked: button_checked
                    required property int index
                    required property bool button_checked
                    required property string column_name
                    required property string column_name_translation
                    property int element_id_with_focus_wrapper: element_id_with_focus

                    onElement_id_with_focus_wrapperChanged: {
                        if(element_id_with_focus === index) checkbox.setFocus(Enums.FocusDir.Right);
                    }

                    onNextFocus: function next_focus(dir) {
                        if(dir === Enums.FocusDir.Close || dir === Enums.FocusDir.Save) button_selection.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Up || dir === Enums.FocusDir.Down) button_selection.nextFocus(dir);
                        else if(dir === Enums.FocusDir.Left) element_id_with_focus = index - 1;
                        else element_id_with_focus = index + 1;
                    }

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