import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "window"
import "tabs"
import "dialogs"

ApplicationWindow
{
    id: rootWindow
    title: "Organization Data Management" + " - " + db_path_text
    width: 400
    height: 600
    minimumWidth: 300
    minimumHeight: 500
    visible: true
    color: backgroundColor

    // Colors
    property color backgroundColor: "#000000"
    property color backgroundColor1: "#303030"
    property color backgroundColor2: "#535353"
    property color backgroundColor3: "#9f9f9f"
    property color backgroundColorError: "#B35150"
    property color backgroundColorNotification: "#51b350"
    property color highlightColor: "#00EF00"
    property color textColor: "#ffffff"
    property color selectedColor: "#4098DB"

    // Text size
    property real textSize: 12.0
    property real textSizeBig: 15.0
    property real textSizeSmall: 10.0

    // Global variables
    property string loaded_db_path: ""  // alway showing the real database path
    property string db_path_text: new_db_text  // database path for the user (e.g. showing "New File" instead of path tp template)
    property string new_db_text: qsTr("New File")  // text shown when a new database is created that is not yet saved
    property string error_message: ""
    property int max_derivate_windows: 5
    property string db_version
    property string saved_date: new_db_text
    property string created_date: new_db_text

    onError_messageChanged: console.log("error msg:", error_message)
    // TODO implement auto deletion of messages after x seconds

    // Locally used variables
    property bool close_okay: false

    // Connections
    Connections {
        target: database
        function onDatabaseLoaded(db_path) { 
            const db_metadata = database.getDBMetadata();
            db_version = db_metadata[0];

            if(db_path === "")
            {
                db_path_text = new_db_text;
                loaded_db_path = db_path;
                saved_date = new_db_text;
                created_date = new_db_text;
            }
            else {
                db_path_text = db_path;
                loaded_db_path = db_path;

                saved_date = db_metadata[1];
                created_date = db_metadata[2];
            }
        }
    }

    // Startup procedure
    Component.onCompleted: {
        database.init_db();

        const db_metadata = database.getDBMetadata();
        db_version = db_metadata[0];
    }

    // Menu Bar
    menuBar: MenuBar { id: menu_bar }

    // Status Bar
    footer: StatusBar
    {
        width: parent.width
        height: menu_bar.height * 0.7
    }

    // Contents
    TabBarMain
    {
        anchors.fill: parent
    }

    // Closing handler
    FileCloseDialog 
    {
        id: close_dialog
        function callback_function() { close_okay = true; rootWindow.close(); }
    }
    onClosing: (close) => {
        close.accepted = false;
        close_dialog.show();

        if(close_okay) close.accepted = true;
    }

    // Dialog Windows
    OrganizationEditDialog
    {
        id: organization_edit_dialog
        pk_id: -1
    }

    AddressEditDialog
    {
        id: address_edit_dialog
        pk_id: -1
    }

    PersonEditDialog
    {
        id: person_edit_dialog
        pk_id: -1
    }
}