import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Item
{
    enum FocusDir {
        Up = -2,
        Left = -1,
        Right = 1,
        Down = 2,
        Save = 10,
        Close = 11
    }

    enum StatusMsgLvl {
        Default,
        Info,
        Warn,
        Err
    }
}