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
    signal shortcutDuplicate()
    signal shortcutNew()
    signal shortcutOpen()

    Shortcut
    {
        sequence: StandardKey.Save
        autoRepeat: false
        onActivated: shortcutSave()
    }

    Shortcut
    {
        sequences: [StandardKey.SaveAs, "Ctrl+Shift+S"]
        autoRepeat: false
        onActivated: shortcutSaveAs()
    }

    Shortcut
    {
        sequences: [StandardKey.Quit, StandardKey.Close]
        autoRepeat: false
        onActivated: shortcutClose()
    }

    Shortcut
    {
        sequence: StandardKey.Delete
        autoRepeat: false
        onActivated: shortcutDelete()
    }

    Shortcut
    {
        sequence: "Ctrl+D"
        autoRepeat: false
        onActivated: shortcutDuplicate()
    }

    Shortcut
    {
        sequence: StandardKey.New
        autoRepeat: false
        onActivated: shortcutNew()
    }

    Shortcut
    {
        sequence: StandardKey.Open
        autoRepeat: false
        onActivated: shortcutOpen()
    }
}