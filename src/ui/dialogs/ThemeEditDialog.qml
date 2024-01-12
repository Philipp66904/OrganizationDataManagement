import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../components"
import "../types"

ApplicationWindow
{
    id: dialog
    title: "Edit Color Theme"
    color: backgroundColor1
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 140
    width: 500
    height: 300

    // Closing handler
    property bool close_okay: false

    FileCloseDialog 
    {
        id: abort_dialog
        function callback_function() { dialog.close_okay = true; dialog.close(); }
    }
    onClosing: (close) => {
        close.accepted = false;
        if(!close_okay) {
            abort_dialog.show();
        }

        if(close_okay) close.accepted = true;
    }

    ListModel
    {
        id: color_theme_list_model
    }

    function init() {
        save_button.setFocus(Enums.FocusDir.Right);
    }

    function initListModel() {
        close_okay = false;
        color_theme_list_model.clear();

        const colors = settings.getThemeColors();
        for(const color of colors) {
            const color_name = color[0];
            const color_value = Qt.color(color[1]);
            
            color_theme_list_model.append({"color_name": color_name, "color_value": color_value});
        }
        init();
    }

    Column
    {
        id: theme_edit_column
        height: parent.height - 8
        width: parent.width
        anchors.top: parent.top
        spacing: 4
        property int row_count: 1
        property var title_rect_height: (height - (row_count - 1) * spacing) * 0.15
        property var theme_edit_list_view_height: (height - (row_count - 1) * spacing) * 0.85

        Rectangle
        {
            id: title_rect
            height: parent.title_rect_height
            width: parent.width
            color: backgroundColor2

            Text
            {
                id: title_text
                anchors.fill: parent
                anchors.margins: 4
                text: qsTr("Edit Color Theme")
                font.pointSize: textSizeBig
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.bold: true
            }
        }

        ListView
        {
            id: theme_edit_list_view
            width: parent.width - 8
            height: theme_edit_column.theme_edit_list_view_height
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            model: color_theme_list_model
            spacing: 8

            delegate: ColorSelection
            {
                width: theme_edit_list_view.width
                height: theme_edit_list_view.height / 4

                required property int index
                required property string color_name
                required property color color_value
                description_text: color_name
                selected_color: color_value

                onSelected_colorChanged: {
                    color_theme_list_model.set(index, {"color_value": selected_color});
                }
            }

            ScrollBar.vertical: ScrollBar
            {
                parent: theme_edit_list_view
                anchors.right: parent.right
            }
        }
    }

    footer:
        Row
        {
            height: 27
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            property int column_count: 3

            BasicButton
            {
                id: save_button
                text: qsTr("Save")
                height: parent.height - anchors.bottomMargin
                width: (parent.width - ((parent.column_count - 1) * parent.spacing)) / parent.column_count
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                highlight_color: highlightColor
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save) clicked();
                    else if(dir === Enums.FocusDir.Close) abort_button.setFocus();
                    else if(dir === Enums.FocusDir.Left) abort_button.setFocus();
                    else if(dir === Enums.FocusDir.Right) reset_button.setFocus();
                }

                onClicked: {
                    for(let i = 0; i < color_theme_list_model.count; i++) {
                        const color_name = color_theme_list_model.get(i).color_name;
                        const color_value = color_theme_list_model.get(i).color_value;

                        settings.slot_setThemeColor(color_name, color_value);
                    }

                    close_okay = true;
                    close();
                    init_colors();
                    setStatusMessage(qsTr("Colors saved and applied"), Enums.StatusMsgLvl.Info);
                }
            }

            BasicButton
            {
                id: reset_button
                text: qsTr("Reset")
                height: parent.height - anchors.bottomMargin
                width: (parent.width - ((parent.column_count - 1) * parent.spacing)) / parent.column_count
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                hover_color: backgroundColorError
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save) save_button.setFocus();
                    else if(dir === Enums.FocusDir.Close) abort_button.setFocus();
                    else if(dir === Enums.FocusDir.Left) save_button.setFocus();
                    else if(dir === Enums.FocusDir.Right) abort_button.setFocus();
                }

                onClicked: {
                    settings.slot_resetThemeColors();
                    close_okay = true;
                    close();
                    initListModel();
                    init_colors();
                    setStatusMessage(qsTr("Colors reset"), Enums.StatusMsgLvl.Info);
                }
            }

            BasicButton
            {
                id: abort_button
                text: qsTr("Abort")
                height: parent.height - anchors.bottomMargin
                width: (parent.width - ((parent.column_count - 1) * parent.spacing)) / parent.column_count
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                hover_color: textColor
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save) save_button.setFocus();
                    else if(dir === Enums.FocusDir.Close) clicked();
                    else if(dir === Enums.FocusDir.Left) reset_button.setFocus();
                    else if(dir === Enums.FocusDir.Right) save_button.setFocus();
                }

                onClicked: {
                    close();
                }
            }
        }

    function callback_function() {}
}