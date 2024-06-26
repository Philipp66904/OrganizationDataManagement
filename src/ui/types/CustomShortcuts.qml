import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Item
{
    signal shortcutSave()
    signal shortcutSaveAs()
    signal shortcutClose()
    signal shortcutDelete()
    signal shortcutNew()
    signal shortcutOpen()

    property bool shortcutSaveEnabled: false
    property bool shortcutSaveAsEnabled: false
    property bool shortcutCloseEnabled: false
    property bool shortcutDeleteEnabled: false
    property bool shortcutNewEnabled: false
    property bool shortcutOpenEnabled: false

    function getSequence(shortcut_name) {
        switch(shortcut_name) {
            case "Save":
                return shortcut_save.getSequence();
            case "Save As":
                return shortcut_save_as.getSequence();
            case "Close":
                return shortcut_close.getSequence();
            case "Delete":
                return shortcut_delete.getSequence();
            case "New":
                return shortcut_new.getSequence();
            case "Open":
                return shortcut_open.getSequence();
            default:
                return "shortcut_name not recognized";
        }
    }

    Shortcut
    {
        id: shortcut_save
        sequence: StandardKey.Save
        autoRepeat: false
        onActivated: shortcutSave()
        enabled: shortcutSaveEnabled

        function getSequence() {
            return nativeText;
        }
    }

    Shortcut
    {
        id: shortcut_save_as
        sequences: [StandardKey.SaveAs, "Ctrl+Shift+S"]
        autoRepeat: false
        onActivated: shortcutSaveAs()
        enabled: shortcutSaveAsEnabled

        function getSequence() {
            var sequenceText = "";
            for (var i = 0; i < sequences.length; i++) {
                if(i > 0) sequenceText += ", ";

                if(sequences[i].nativeText !== undefined) {
                    sequenceText += sequences[i].nativeText;
                } else if (isNaN(sequences[i])) {
                    sequenceText += sequences[i];
                } else {
                    sequenceText += qsTr("undefined");
                }
            }
            return sequenceText;
        }
    }

    Shortcut
    {
        id: shortcut_close
        sequences: [StandardKey.Quit, StandardKey.Close]
        autoRepeat: false
        onActivated: shortcutClose()
        enabled: shortcutCloseEnabled

        function getSequence() {
            var sequenceText = "";
            for (var i = 0; i < sequences.length; i++) {
                if(i > 0) sequenceText += ", ";

                if(sequences[i].nativeText !== undefined) {
                    sequenceText += sequences[i].nativeText;
                } else if (isNaN(sequences[i])) {
                    sequenceText += sequences[i];
                } else {
                    sequenceText += qsTr("undefined");
                }
            }
            return sequenceText;
        }
    }

    Shortcut
    {
        id: shortcut_delete
        sequence: StandardKey.Delete
        autoRepeat: false
        onActivated: shortcutDelete()
        enabled: shortcutDeleteEnabled

        function getSequence() {
            return nativeText;
        }
    }

    Shortcut
    {
        id: shortcut_new
        sequence: StandardKey.New
        autoRepeat: false
        onActivated: shortcutNew()
        enabled: shortcutNewEnabled

        function getSequence() {
            return nativeText;
        }
    }

    Shortcut
    {
        id: shortcut_open
        sequence: StandardKey.Open
        autoRepeat: false
        onActivated: shortcutOpen()
        enabled: shortcutOpenEnabled

        function getSequence() {
            return nativeText;
        }
    }
}