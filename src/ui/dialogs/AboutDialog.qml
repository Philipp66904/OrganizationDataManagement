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
    title: qsTr("About") + " - " + qsTr("Organization Data Management")
    color: backgroundColor1
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 200
    width: 500
    height: 300

    CustomShortcuts
    {
        id: custom_shortcuts

        onShortcutClose: {
            dialog.close();
        }
    }

    function init() {
        // Call this function before .show()
        let res = "";

        res += "# " + qsTr("General");
        res += "  \n";
        res += qsTr("By") + " **" + qsTr("Philipp Grueber") + "**  \n";
        res += "*" + qsTr("Visit Github for more information.") + "*";
        res += "  \n";
        res += "**" + qsTr("Currently loaded file") + "**: *" + db_path_text + "*";
        res += "  \n";

        res += "# " + qsTr("Keyboard Shortcuts");
        res += "  \n";
        res += "**" + qsTr("Save") + "**: `" + custom_shortcuts.getSequence("Save") + "`";
        res += "  \n";
        res += "**" + qsTr("Save As") + "**: `" + custom_shortcuts.getSequence("Save As") + "`";
        res += "  \n";
        res += "**" + qsTr("Close") + "**: `" + custom_shortcuts.getSequence("Close") + "`";
        res += "  \n";
        res += "**" + qsTr("Delete") + "**: `" + custom_shortcuts.getSequence("Delete") + "`";
        res += "  \n";
        res += "**" + qsTr("New") + "**: `" + custom_shortcuts.getSequence("New") + "`";
        res += "  \n";
        res += "**" + qsTr("Open") + "**: `" + custom_shortcuts.getSequence("Open") + "`";
        res += "  \n";

        res += "# " + qsTr("Versions");
        res += "  \n";
        res += "**" + qsTr("UI version") + "**: `" + ui_version + "`";
        res += "  \n";
        if(database) {
            res += "**" + qsTr("DB Core version") + "**: `" + database.getDBCoreVersion() + "`";
            res += "  \n";
            res += "**" + qsTr("Supported DB version") + "**: `" + database.getSupportedDBVersion() + "`";
            res += "  \n";
        }
        if(settings) {
            res += "**" + qsTr("Supported settings version") + "**: `" + settings.getSupportedSettingsVersion() + "`";
            res += " - " + "**" + qsTr("Loaded settings version") + "**: `" + settings.getLoadedSettingsVersion() + "`";
            res += "  \n";
        }

        about_text.text = res;
    }

    Column
    {
        width: parent.width
        height: parent.height
        anchors.fill: parent
        spacing: 4
        property int row_count: 2

        Rectangle
        {
            id: headline_rect
            width: parent.width
            height: Math.min((parent.height - (parent.spacing * parent.row_count)) * 0.15, 43.8)
            color: backgroundColor2
            focus: true

            Row
            {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8

                Text
                {
                    id: title_text
                    width: (parent.width - parent.spacing) * 0.3
                    height: parent.height
                    text: qsTr("About")
                    font.pointSize: fontSize_big
                    font.family: fontFamily_big
                    color: textColor
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font.bold: true
                }

                Text
                {
                    id: title_text_description
                    width: (parent.width - parent.spacing) * 0.7
                    height: parent.height
                    text: qsTr("Organization Data Management")
                    font.pointSize: fontSize_big
                    font.family: fontFamily_big
                    color: textColor1
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        ScrollView
        {
            id: about_text_scroll_view
            height: (parent.height - (parent.spacing * parent.row_count)) - headline_rect.height
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            contentWidth: about_text_scroll_view.width
            contentHeight: about_text.height

            Text
            {
                id: about_text
                text: ""
                width: about_text_scroll_view.width
                font.pointSize: fontSize_default
                font.family: fontFamily_default
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                lineHeight: 1.3
                wrapMode: Text.Wrap
                textFormat: Text.MarkdownText
            }
        }
    }
}