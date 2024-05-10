import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../types"

Rectangle
{
    id: property_line_edit_root
    color: {
        if(root_mouse_area.containsMouse) return backgroundColor2;
        else return "transparent";
    }
    border.color: {
        if(!required) {
            if(editing) return highlightColor;
            else return color;
        }
        else {
            if(!validator(value_text.text)) return backgroundColorError;
            else if(editing) return highlightColor;
            else return color;
        }
    }
    border.width: 1
    radius: 4

    property var null_switch_height_percentage: 0.7
    property bool required: false

    property bool editing: value_text.activeFocus
    property bool derivative_mode: true
    required property string description
    required property var value
    required property var derivative_value
    property bool derivative_flag: false

    // Action button
    property bool action_button: false
    property string action_button_image_src: "../res/svg/link_icon.svg"
    signal action_button_clicked()

    onDerivative_flagChanged: value_text.text = getValueText()
    onDerivative_valueChanged: value_text.text = getValueText()
    onValueChanged: value_text.text = getValueText()

    MouseArea
    {
        id: root_mouse_area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    function init(derivative_flag_arg) {
        // Call this function whenever new properties are loaded
        if(derivative_flag_arg !== undefined) {
            null_switch.start_value = derivative_flag_arg;
            null_switch.setState(derivative_flag_arg);
        }
        else {
            null_switch.start_value = derivative_flag;
            null_switch.setState(derivative_flag);
        }
    }

    signal new_value(val: string, derivative_flag: bool, undefined_flag: bool)

    function getValueText() {
        if(derivative_flag) {
            if(derivative_value !== undefined) return derivative_value;
            else return "";
        }
        else {
            if(value === undefined) return "";
            else return value;
        }
    }

    function setFocus(dir) {
        value_text.forceActiveFocus();
        focusSet();
    }

    signal nextFocus(dir: int)
    signal focusSet()

    // Overwrite function with individual validator
    // Only works if required is set to true as well
    function validator(text) {
        // Returns true if the input is valid, otherwise false
        return !(text.trim().length <= 0);
    }

    Row
    {
        id: property_row_main
        anchors.fill: parent
        anchors.margins: 4
        spacing: 8
        property int column_count: 2 + ((derivative_mode) ? 1 : 0) + ((action_button) ? 1 : 0)

        property int description_text_width: (width - (column_count * spacing)) * 0.3
        property int value_text_width: {
            let factor = 0.7;
            if(derivative_mode) factor -= 0.2;
            if(action_button) factor -= 0.1;

            return (width - (column_count * spacing)) * factor;
        }
        property int null_switch_width: (width - (column_count * spacing)) * 0.2
        property int action_button_width: (width - (column_count * spacing)) * 0.1

        function send_new_value() {
            if(derivative_flag) {
                value_text.text = (derivative_value !== undefined) ? derivative_value : "";

                if(derivative_value === undefined) {
                    property_line_edit_root.new_value("", derivative_flag, true);
                }
                else {
                    property_line_edit_root.new_value(derivative_value, derivative_flag, false);
                }
            }
            else {
                property_line_edit_root.new_value(value_text.text, derivative_flag, false);
            }
        }

        function toggleDerivative(new_derivative_flag) {
            derivative_flag = new_derivative_flag;

            if(new_derivative_flag) {
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
            font.pointSize: fontSize_default
            font.family: fontFamily_default
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
            font.pointSize: fontSize_default
            font.family: fontFamily_default
            color: (derivative_flag) ? backgroundColor3 : textColor
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            clip: true
            font.italic: (derivative_flag) ? true : false
            readOnly: derivative_flag
            Keys.onTabPressed: nextFocus(Enums.FocusDir.Right);
            Keys.onReturnPressed: nextFocus(Enums.FocusDir.Save);
            Keys.onEscapePressed: nextFocus(Enums.FocusDir.Close);
            Keys.onBacktabPressed: nextFocus(Enums.FocusDir.Left);
            Keys.onUpPressed: nextFocus(Enums.FocusDir.Up);
            Keys.onDownPressed: nextFocus(Enums.FocusDir.Down);

            onActiveFocusChanged: {
                if(activeFocus && derivative_flag) {
                    null_switch.setState(false);
                    property_row_main.toggleDerivative(false);
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

        SimpleButton
        {
            id: action_button_obj
            visible: action_button
            width: property_row_main.action_button_width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            simple_button_image_src: action_button_image_src

            onClicked: {
                action_button_clicked();
            }
        }

        CustomSlider
        {
            id: null_switch
            visible: derivative_mode
            width: property_row_main.null_switch_width
            height: parent.height * null_switch_height_percentage
            anchors.verticalCenter: parent.verticalCenter
            start_value: false

            onToggled: function toggle_handler(checked) {
                property_row_main.toggleDerivative(checked);
            }
        }
    }
}