import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle
{
    id: property_paragraph_edit_root
    color: backgroundColor2
    border.color: (editing) ? highlightColor : color
    border.width: 1
    radius: 4

    property bool editing: value_text.focus
    required property string description
    required property string value
    required property string original_value
    property bool derivate_flag: false

    signal new_value(val: string, derivate_flag: bool)

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
                if(derivate_flag) {
                    value_text.text = original_value;
                    property_paragraph_edit_root.new_value(value, derivate_flag);
                }
                else {
                    property_paragraph_edit_root.new_value(value_text.text, derivate_flag);
                }
            }

            Text
            {
                id: description_text
                text: description + ":"
                width: property_row_main.description_text_width
                height: parent.height
                font.pointSize: textSize
                color: textColor1
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        TextInput
        {
            id: value_text
            text: (derivate_flag) ? original_value : value
            width: parent.width
            height: (parent.height - (parent.spacing * parent.row_count)) - property_row_main.height
            font.pointSize: textSize
            color: (derivate_flag) ? backgroundColor3 : textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignTop
            clip: true
            font.italic: (derivate_flag) ? true : false
            readOnly: derivate_flag
            wrapMode: TextEdit.Wrap

            onTextEdited: {
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