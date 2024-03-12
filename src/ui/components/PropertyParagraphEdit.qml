import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../types"

Rectangle
{
    id: property_paragraph_edit_root
    color: (root_mouse_area.containsMouse) ? backgroundColor2 : "transparent"
    border.color: (editing) ? highlightColor : backgroundColor2
    border.width: 1
    radius: 4

    property bool editing: value_text.activeFocus
    required property string description
    required property string value
    required property string original_value
    property bool derivative_flag: false

    signal new_value(val: string, derivative_flag: bool)

    function setFocus(dir) {
        value_text.forceActiveFocus();
        focusSet();
    }

    signal nextFocus(dir: int)
    signal focusSet()

    MouseArea
    {
        id: root_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Column
    {
        id: property_column_main
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8
        property int row_count: 2

        Row
        {
            id: property_row_main
            anchors.horizontalCenter: parent.horizontalCenter
            height: description_text.contentHeight
            width: parent.width
            spacing: 8
            property int column_count: 1

            property int description_text_width: (width - (column_count * spacing)) * 1.0

            function send_new_value() {
                if(derivative_flag) {
                    value_text.text = original_value;
                    property_paragraph_edit_root.new_value(value, derivative_flag);
                }
                else {
                    property_paragraph_edit_root.new_value(value_text.text, derivative_flag);
                }
            }

            Text
            {
                id: description_text
                text: description + ":"
                width: property_row_main.description_text_width
                height: parent.height
                font.pointSize: fontSize_default
                font.family: fontFamily_default
                color: textColor1
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Flickable
        {
            id: flick
            width: parent.width
            height: (parent.height - (parent.spacing * parent.row_count)) - property_row_main.height
            contentWidth: width
            contentHeight: Math.max(value_text.contentHeight, value_text.height)
            clip: true
            interactive: value_text.contentHeight > height

            Behavior on contentY { SmoothedAnimation { velocity: 200 } }

            ScrollBar.vertical: ScrollBar
            {
                parent: flick
                anchors.right: parent.right
            }

            function ensureVisible(r)
            {
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y+r.height)
                    contentY = r.y+r.height-height;
            }
        
            TextEdit
            {
                id: value_text
                text: (derivative_flag) ? original_value : value
                width: parent.width
                font.pointSize: fontSize_default
                font.family: fontFamily_default
                color: (derivative_flag) ? backgroundColor3 : textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                font.italic: (derivative_flag) ? true : false
                readOnly: derivative_flag
                wrapMode: TextEdit.Wrap
                Keys.onTabPressed: nextFocus(Enums.FocusDir.Right);
                Keys.onBacktabPressed: nextFocus(Enums.FocusDir.Left);
                Keys.onEscapePressed: nextFocus(Enums.FocusDir.Close);

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Up) {
                        if(cursorRectangle.y === 0) {
                            event.accepted = true;
                            nextFocus(Enums.FocusDir.Up);
                        }
                    } else if (event.key === Qt.Key_Down) {
                        if(cursorRectangle.y === (flick.contentHeight - cursorRectangle.height)) {
                            event.accepted = true;
                            nextFocus(Enums.FocusDir.Down);
                        }
                    } else if (event.key === Qt.Key_Return && (event.modifiers & Qt.ControlModifier)) {
                        event.accepted = true;
                        nextFocus(Enums.FocusDir.Save);
                    }
                }

                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)

                onTextChanged: {
                    property_row_main.send_new_value();
                }

                Rectangle
                {
                    id: value_text_underline
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: (editing) ? highlightColor : backgroundColor3
                    height: 1
                    width: parent.width
                }
            }

            MouseArea
            {
                anchors.fill: parent
                enabled: false
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton
            }
        }
    }
}