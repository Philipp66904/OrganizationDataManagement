import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

Rectangle  // statusbar in the window's footer
{
    id: statusbar
    color: "transparent"
    border.color: backgroundColor1
    border.width: 1

    Row
    {
        id: statusbar_row
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        property int row_items_count: 3
        property int spacing_width: 1

        Component
        {
            id: spacing_component

            Rectangle
            {
                height: statusbar_row.height
                width: statusbar_row.spacing_width
                color: backgroundColor1
                radius: 1
            }
        }

        Rectangle
        {
            height: parent.height
            width: ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count
            color: "transparent"

            Text
            {
                id: db_path_text
                anchors.fill: parent
                anchors.margins: 4
                text: new_db_text
                font.pointSize: textSizeSmall
                color: textColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideLeft

                property var new_db_text: qsTr("New Database")

                Connections {
                    target: database
                    function onDatabaseLoaded(db_path) { 
                        if(db_path === "")
                        {
                            db_path_text.text = db_path_text.new_db_text;
                            loaded_db_path = db_path;
                        }
                        else {
                            db_path_text.text = db_path;
                            loaded_db_path = db_path;
                        }
                    }
                }
            }
        }

        Loader { sourceComponent: spacing_component }

        Rectangle
        {
            height: parent.height
            width: ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count
            color: "transparent"
        }

        Loader { sourceComponent: spacing_component }

        Rectangle
        {
            height: parent.height
            width: ( parent.width 
                    - (statusbar_row.spacing_width * (statusbar_row.row_items_count - 1))
                    - ((statusbar_row.row_items_count - 1) * 2 * parent.spacing)
                    ) / statusbar_row.row_items_count
            color: "transparent"
        }
    }
}