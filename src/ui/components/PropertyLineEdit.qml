import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle
{
    id: property_line_edit_root
    color: backgroundColor2
    border.color:
    {
        if(!required) {
            if(editing) return highlightColor;
            else return color;
        }
        else {
            if(value_text.text.trim().length <= 0) return backgroundColorError;
            else if(editing) return highlightColor;
            else return color;
        }
    }
    border.width: 1
    radius: 4

    property var null_switch_height_percentage: 0.7
    property bool required: false

    property bool editing: value_text.focus
    property bool derivate_mode: true
    required property string description
    required property var value
    required property var derivate_value
    property bool derivate_flag: false

    onDerivate_flagChanged: value_text.text = getValueText()
    onDerivate_valueChanged: value_text.text = getValueText()
    onValueChanged: value_text.text = getValueText()

    function init(derivate_flag_arg) {
        // Call this function whenever new properties are loaded
        if(derivate_flag_arg !== undefined) {
            null_switch.start_value = derivate_flag_arg;
            null_switch.setState(derivate_flag_arg);
        }
        else {
            null_switch.start_value = derivate_flag;
            null_switch.setState(derivate_flag);
        }
    }

    signal new_value(val: string, derivate_flag: bool, undefined_flag: bool)

    function getValueText() {
        if(derivate_flag) {
            if(derivate_value !== undefined) return derivate_value;
            else return "";
        }
        else {
            if(value === undefined) return "";
            else return value;
        }
    }

    Row
    {
        id: property_row_main
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8
        property int column_count: (derivate_mode) ? 3 : 2

        property int description_text_width: (width - (column_count * spacing)) * 0.3
        property int value_text_width: (derivate_mode) ? (width - (column_count * spacing)) * 0.5 : (width - (column_count * spacing)) * 0.7
        property int null_switch_width: (width - (column_count * spacing)) * 0.2

        function send_new_value() {
            if(derivate_flag) {
                value_text.text = (derivate_value !== undefined) ? derivate_value : "";

                if(derivate_value === undefined) {
                    property_line_edit_root.new_value("", derivate_flag, true);
                }
                else {
                    property_line_edit_root.new_value(derivate_value, derivate_flag, false);
                }
            }
            else {
                property_line_edit_root.new_value(value_text.text, derivate_flag, false);
            }
        }

        function toggleDerivate(new_derivate_flag) {
            derivate_flag = new_derivate_flag;

            if(new_derivate_flag) {
                if(value === undefined) value_text.text = "";
                else value_text.text = value;
            }

            property_row_main.send_new_value();
        }

        Text
        {
            id: description_text
            text: description + ":"
            width: property_row_main.description_text_width
            height: parent.height
            font.pointSize: textSize
            color: (required && value_text.text.trim().length <= 0) ? backgroundColorError : textColor1
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        TextInput
        {
            id: value_text
            text: getValueText()
            width: property_row_main.value_text_width
            height: parent.height
            font.pointSize: textSize
            color: (derivate_flag) ? backgroundColor3 : textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            clip: true
            font.italic: (derivate_flag) ? true : false
            readOnly: derivate_flag

            onActiveFocusChanged: {
                if(activeFocus && derivate_flag) {
                    null_switch.setState(false);
                    property_row_main.toggleDerivate(false);
                }
            }

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

        CustomSlider
        {
            id: null_switch
            width: property_row_main.null_switch_width
            height: parent.height * null_switch_height_percentage
            anchors.verticalCenter: parent.verticalCenter
            start_value: false
            visible: derivate_mode

            onToggled: function toggle_handler(checked) {
                property_row_main.toggleDerivate(checked);
            }
        }
    }
}