import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../types"

Rectangle
{
    id: combo_selection_root
    color: (root_mouse_area.containsMouse) ? backgroundColor2 : "transparent"
    border.color: (popup_opened || combo_selection.activeFocus) ? highlight_color : color
    border.width: 1
    radius: 4

    required property string description_text
    property int selected_index: -1  // currently selected database index; -1 if no option is chosen
    property bool not_null: true
    property color highlight_color: highlightColor

    property bool popup_opened: combo_selection.popup.opened

    function setFocus(dir) {
        combo_selection.forceActiveFocus();
        focusSet();
    }

    signal nextFocus(dir: int)
    signal focusSet()

    function setCurrentIndex(new_selected_index) {
        combo_selection.currentIndex = new_selected_index;
    }

    ListModel
    {
        id: combo_selection_list_model
    }

    function load_data(input_list) {
        combo_selection_list_model.clear();

        for (let input of input_list) {
            let name_note = input[1];
            if(input[2].trim().length > 0) name_note += " ・ " + input[2];

            combo_selection_list_model.append({"id": input[0], "name": input[1], "note": input[2],
                                               "name_note": name_note});
        }

        if (input_list.length > 0) {
            if(!not_null) {
                combo_selection_list_model.insert(0, {"id": -1, "name": "", "note": "",
                                                "name_note": ""});
            }

            combo_selection.currentIndex = 0;
            selected_index = combo_selection_list_model.get(combo_selection.currentIndex).id;
        }
        else {
            combo_selection.currentIndex = -1;
            selected_index = -1;
        }
    }

    Row
    {
        id: combo_selection_row
        anchors.fill: parent
        spacing: 8
        property int column_count: 2
        anchors.margins: 4

        Text
        {
            id: description
            text: combo_selection_root.description_text
            height: parent.height
            width: (parent.width - (parent.spacing * (combo_selection_row.column_count - 1))) / combo_selection_row.column_count
            font.pointSize: fontSize_default
            font.family: fontFamily_default
            color: textColor1
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        ComboBox
        {
            id: combo_selection
            height: parent.height
            width: (parent.width - (parent.spacing * (combo_selection_row.column_count - 1))) / combo_selection_row.column_count
            model: combo_selection_list_model
            popup.modal: true
            textRole: "name_note"
            anchors.verticalCenter: parent.verticalCenter
            Keys.onTabPressed: nextFocus(Enums.FocusDir.Right);
            Keys.onBacktabPressed: nextFocus(Enums.FocusDir.Left);
            Keys.onLeftPressed: nextFocus(Enums.FocusDir.Left);
            Keys.onRightPressed: nextFocus(Enums.FocusDir.Right);
            Keys.onReturnPressed: nextFocus(Enums.FocusDir.Save);

            onCurrentIndexChanged: {
                if (currentIndex >= combo_selection_list_model.length || currentIndex < 0) {
                    selected_index = -1;
                }
                else {
                    selected_index = combo_selection_list_model.get(currentIndex).id;
                }
            }
        }
    }

    MouseArea
    {
        id: root_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}