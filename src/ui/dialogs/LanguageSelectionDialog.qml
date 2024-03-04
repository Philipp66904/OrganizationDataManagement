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
    title: qsTr("Change Language")
    color: backgroundColor1
    modality: Qt.ApplicationModal
    flags: Qt.Dialog
    minimumWidth: 300
    minimumHeight: 120
    width: 300
    height: 120

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
        main_text: qsTr("The language will be set to the default value.")
        sub_text: qsTr("Do you want to proceed?")
        ok_text: qsTr("Reset Language")
        abort_text: qsTr("Abort")

        function callback_function() {
            const active_language = (settings.getAvailableLanguages())[0];
            settings.slot_setActiveLanguage(active_language);
            
            dialog.close_okay = true;
            dialog.close();
            setStatusMessage(qsTr("Restart program for new language"), Enums.StatusMsgLvl.Info);
        }
    }

    function init() {
        save_button.setFocus(Enums.FocusDir.Right);

        const langs = settings.getAvailableLanguages();
        const active_language = settings.getActiveLanguage();
        let langs_res = []
        let i = 0;
        let selected_language = 0;
        for(let language of langs) {
            if(language === active_language) {
                selected_language = i;
            }

            let lang_tmp = language;
            if(lang_tmp === "Follow System") lang_tmp = qsTr("Follow System");
            else if(lang_tmp === "English Development (Fallback)") lang_tmp = qsTr("English Development (Fallback)");

            langs_res.push([i, lang_tmp, ""]);
            i += 1;
        }

        language_combo_selection.load_data(langs_res);

        // Preselect active language
        language_combo_selection.setCurrentIndex(selected_language);
    }

    Column
    {
        id: language_selection_column
        height: parent.height - 8
        width: parent.width
        anchors.top: parent.top
        spacing: 4
        property int row_count: 1
        property var title_rect_height: (height - (row_count - 1) * spacing) * 0.4
        property var language_combo_selection_height: (height - (row_count - 1) * spacing) * 0.6

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
                text: qsTr("Select Language")
                font.pointSize: fontSize_big
                font.family: fontFamily_big
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.bold: true
            }
        }

        ComboSelection
        {
            id: language_combo_selection
            width: parent.width - 8
            height: language_selection_column.language_combo_selection_height
            anchors.horizontalCenter: parent.horizontalCenter
            description_text: qsTr("Language")
            not_null: true
            onNextFocus: function next_focus(dir) {
                if(dir === Enums.FocusDir.Save) save_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                else if(dir === Enums.FocusDir.Right || dir === Enums.FocusDir.Down) save_button.setFocus(dir);
                else abort_button.setFocus(dir);
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
                    else if(dir === Enums.FocusDir.Close) abort_button.setFocus(dir);
                    else if(dir === Enums.FocusDir.Right) reset_button.setFocus(dir);
                    else language_combo_selection.setFocus(dir);
                }

                onClicked: {
                    const active_language = (settings.getAvailableLanguages())[language_combo_selection.selected_index];
                    settings.slot_setActiveLanguage(active_language);

                    close_okay = true;
                    close();
                    setStatusMessage(qsTr("Restart program for new language"), Enums.StatusMsgLvl.Info);
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
                    else language_combo_selection.setFocus(dir);
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
                    else language_combo_selection.setFocus(dir);
                }

                onClicked: {
                    close();
                }
            }
        }
}