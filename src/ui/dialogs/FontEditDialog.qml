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
    title: qsTr("Edit Font Sizes")
    color: backgroundColor1
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 250
    width: 350
    height: 250

    // Closing handler
    property bool close_okay: false

    UnsavedChangesCloseDialog 
    {
        id: abort_dialog
        function callback_function() { dialog.close_okay = true; dialog.close(); }
    }
    onClosing: (close) => {
        close.accepted = false;
        if(!close_okay) {
            abort_dialog.init();
            abort_dialog.show();
        }

        if(close_okay) close.accepted = true;
    }

    TemplateDialog
    {
        id: reset_dialog

        title_text: qsTr("Do you want to proceed?")
        main_text: qsTr("The fonts will be set to the default values.")
        sub_text: qsTr("Do you want to proceed?")
        ok_text: qsTr("Reset Fonts")
        abort_text: qsTr("Abort")

        function callback_function() {
            settings.slot_resetFonts();
            dialog.close_okay = true;
            dialog.close();
            dialog.initListModel();
            init_fonts();
            setStatusMessage(qsTr("Fonts reset"), Enums.StatusMsgLvl.Info);
        }
    }

    ListModel
    {
        id: fonts_list_model
    }

    function init() {
        save_button.setFocus(Enums.FocusDir.Right);
    }

    function initListModel() {
        close_okay = false;
        fonts_list_model.clear();

        const fonts = settings.getFonts();
        for(const font of fonts) {
            const font_name = font[0];
            const font_family = font[1];
            const font_size = font[2];
            
            fonts_list_model.append({"font_name": font_name, "font_family": font_family, "font_size": font_size});
        }
        init();
    }

    Column
    {
        id: font_edit_column
        height: parent.height - 8
        width: parent.width
        anchors.top: parent.top
        spacing: 4
        property int row_count: 3
        property var title_rect_height: Math.min(33, (height - (row_count - 1) * spacing) * 0.20)
        property var font_edit_list_view_height: (height - (row_count - 1) * spacing - title_rect_height - notification_rect_height) * 1.0
        property var notification_rect_height: Math.min(61, (height - (row_count - 1) * spacing - title_rect_height) * 0.35)

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
                text: qsTr("Edit Font Sizes")
                font.pointSize: fontSize_big
                font.family: fontFamily_big
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.bold: true
            }
        }

        ListView
        {
            id: font_edit_list_view
            width: parent.width - 8
            height: font_edit_column.font_edit_list_view_height
            anchors.horizontalCenter: parent.horizontalCenter
            clip: true
            model: fonts_list_model
            spacing: 8

            delegate: PropertyLineEdit
            {
                width: font_edit_list_view.width
                height: Math.min(35, font_edit_list_view.height / 4)

                required property int index
                required property string font_name
                required property string font_family
                required property real font_size

                description: font_name
                value: font_size
                derivative_value: ""
                derivative_mode: false
                required: true
                
                function validator(text) {
                    let new_font_size = parseFloat(text);

                    return (!isNaN(new_font_size)) && (new_font_size > 0.0);
                }

                onNew_value: function update_font(val, _, _) {
                    let new_font_size = parseFloat(val);
                    if(isNaN(new_font_size)) new_font_size = 0.0;

                    fonts_list_model.set(index, {"font_size": new_font_size});
                }
            }

            ScrollBar.vertical: ScrollBar
            {
                parent: font_edit_list_view
                anchors.right: parent.right
            }
        }

        InformationRect
        {
            id: notification_rect
            information_text: qsTr("Font types must be set manually in the settings.json file.")
            multiline: true
            width: parent.width - (parent.spacing * 2)
            height: font_edit_column.notification_rect_height
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    footer:
        Row
        {
            id: button_row
            height: 27
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            property int column_count: 3

            function checkInputs() {
                for(let i = 0; i < fonts_list_model.count; i++) {
                    const font_name = fonts_list_model.get(i).font_name;
                    const font_family = fonts_list_model.get(i).font_family;
                    const font_size = fonts_list_model.get(i).font_size;

                    if(font_family.trim().length <= 0 || isNaN(font_size) || font_size <= 0) return false;
                }

                return true;
            }

            BasicButton
            {
                id: save_button
                text: qsTr("Save")
                height: parent.height - anchors.bottomMargin
                width: (parent.width - ((parent.column_count - 1) * parent.spacing)) / parent.column_count
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                highlight_color: highlightColor
                button_enabled: button_row.checkInputs()
                onNextFocus: function next_focus(dir) {
                    if(dir === Enums.FocusDir.Save) clicked();
                    else if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Left) abort_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Right) reset_button.setFocus(dir);
                }

                onClicked: {
                    for(let i = 0; i < fonts_list_model.count; i++) {
                        const font_name = fonts_list_model.get(i).font_name;
                        const font_family = fonts_list_model.get(i).font_family;
                        const font_size = fonts_list_model.get(i).font_size;

                        settings.slot_setFont(font_name, font_family, font_size);
                    }

                    close_okay = true;
                    close();
                    init_fonts();
                    setStatusMessage(qsTr("Fonts saved and applied"), Enums.StatusMsgLvl.Info);
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
                    if(dir === Enums.FocusDir.Save) save_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Left) save_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Right) abort_button.setFocus(dir);
                }

                onClicked: {
                    reset_dialog.init();
                    reset_dialog.show();
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
                    if(dir === Enums.FocusDir.Save) save_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Close) clicked();
                    else if(dir === Enums.FocusDir.Left) reset_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Right) save_button.setFocus(dir);
                }

                onClicked: {
                    close();
                }
            }
        }
}