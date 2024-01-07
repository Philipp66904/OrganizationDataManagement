import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtPositioning

Rectangle
{
    id: slider_rect_root
    color: "transparent"

    required property bool start_value
    property bool value_output: !start_value

    property color active_color: highlightColor
    property color deactive_color: backgroundColor3

    signal toggled(state: bool)

    function setState(new_state) {
        start_value = new_state;
        custom_slider.value = !new_state;
        value_output = custom_slider.value;
    }

    Slider
    {
        id: custom_slider
        anchors.fill: parent
        from: 0
        to: 1
        value: !start_value
        stepSize: 1
        snapMode: Slider.SnapOnRelease

        onMoved: {
            value_output = custom_slider.value;
            slider_rect_root.toggled(!value_output);
        }

        background: Rectangle
        {
            width: parent.width - custom_slider.leftPadding
            height: parent.height
            radius: height / 2
            color: (value_output) ? active_color : deactive_color
            anchors.horizontalCenter: parent.horizontalCenter
        }

        handle: Rectangle
        {
            x: custom_slider.leftPadding + custom_slider.visualPosition * (custom_slider.availableWidth - width)
            y: custom_slider.topPadding + custom_slider.availableHeight / 2 - height / 2
            height: parent.height - 8
            width: height
            radius: height / 2
            color:
            {
                if(custom_slider.pressed) return backgroundColor3;

                if(value_output) return deactive_color;
                else return active_color;
            }

            MouseArea
            {
                anchors.fill: parent
                enabled: false
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}