import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import tablemodule 1.0

Rectangle
{
    id: table_root
    color: "transparent"
    border.color: backgroundColor1
    border.width: 1
    radius: 8

    // Connections
    Connections {
        target: database
        function onDataChanged() {
            load_data();  // implement function with specific implementation per tab
        }
    }

    Connections {
        target: table_model
        function onUpdateView() {
            table_view.forceLayout()
        }
    }

    Column
    {
        id: main_column
        anchors.fill: parent
        spacing: 4
        anchors.topMargin: margins
        anchors.bottomMargin: margins
        property int margins: 4
        
        Rectangle
        {
            id: table_view_main
            width: parent.width - (main_column.margins * 2)
            height: (parent.height * 0.94) - main_column.spacing
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            Column
            {
                anchors.fill: parent
                spacing: 2

                HorizontalHeaderView
                {
                    id: table_view_header
                    width: table_view.width
                    height: table_view_main.height * 0.07
                    anchors.left: parent.left
                    syncView: table_view
                    clip: true
                    resizableColumns: false

                    delegate: Rectangle {
                        implicitWidth: table_view_main.width * 0.22
                        implicitHeight: table_view_main.height * 0.07
                        color: backgroundColor2
                        border.color: backgroundColor1
                        border.width: 1

                        Text {
                            text: display
                            anchors.fill: parent
                            anchors.margins: 4
                            font.pointSize: textSize
                            font.bold: true
                            color: textColor
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }

                Rectangle
                {
                    id: table_view_separator
                    width: Math.min(table_view_header.contentWidth, parent.width)
                    height: 1
                    anchors.left: table_view_header.left
                    color: backgroundColor1
                }

                TableView {
                    id: table_view
                    width: parent.width
                    height: parent.height - table_view_header.height - separator.height - (parent.spacing * 2)
                    rowSpacing: 4
                    clip: true
                    anchors.left: parent.left
                    resizableColumns: false
                    columnWidthProvider: get_column_width

                    Text
                    {
                        id: dummy_txt
                        visible: false
                        width: table_view_main.width * 0.50 - 8
                        height: table_view_main.height * 0.07 - 8
                        font.pointSize: textSize
                        font.bold: true
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    function get_column_width(column) {
                        dummy_txt.text = table_model.getLongestText(column) + "    ";
                        return dummy_txt.contentWidth;
                    }

                    model: table_model

                    delegate: Rectangle {
                        id: cell_rect
                        implicitWidth: table_view_main.width * 0.22
                        implicitHeight: table_view_main.height * 0.07
                        color: backgroundColor
                        border.color: backgroundColor1
                        border.width: 1

                        Text
                        {
                            id: cell_text
                            text: display
                            anchors.fill: parent
                            anchors.margins: 4
                            font.pointSize: textSize
                            color: textColor
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        Rectangle
        {
            id: separator
            width: parent.width
            height: 1
            color: backgroundColor1
        }

        Rectangle
        {
            id: table_buttons_main
            width: table_view_main.width
            height: parent.height - table_view_main.height - separator.height - (main_column.spacing * 2)
            anchors.horizontalCenter: parent.horizontalCenter
            color: "red"
        }
    }
}