import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "window"
import "tabs"
import "dialogs"
import "types"

ApplicationWindow
{
    id: rootWindow
    title: qsTr("Organization Data Management") + " - " + db_path_text
    width: 400
    height: 600
    minimumWidth: 300
    minimumHeight: 500
    visible: true
    color: backgroundColor

    // Colors
    property color backgroundColor: "#000000"
    property color backgroundColor1: "#1a1a1a"
    property color backgroundColor2: "#363636"
    property color backgroundColor3: "#9f9f9f"
    property color backgroundColorError: "#fc5d5b"
    property color backgroundColorWarning: "#fcc947"
    property color backgroundColorNotification: "#51b350"
    property color highlightColor: "#00ef00"
    property color textColor: "#ffffff"
    property color textColor1: "#cfcfcf"

    // Text family and size
    property string fontFamily_default: "Segoe UI"
    property string fontFamily_small: "Segoe UI"
    property string fontFamily_big: "Segoe UI"
    property real fontSize_default: 12.0
    property real fontSize_small: 10.0
    property real fontSize_big: 15.0

    // Global variables
    readonly property string ui_version: "1.1.0"
    property string loaded_db_path: ""  // alway showing the real database path
    property string db_path_text: new_db_text  // database path for the user (e.g. showing "New File" instead of path tp template)
    property string new_db_text: qsTr("New File")  // text shown when a new database is created that is not yet saved
    property string status_message: default_status_message
    property int status_message_level: default_status_message_level
    property string db_version
    property string saved_date: new_db_text
    property string created_date: new_db_text
    property var locale_obj: undefined

    // Locally used variables
    property bool close_okay: false
    readonly property string default_status_message: qsTr("Ready")
    readonly property int default_status_message_level: Enums.StatusMsgLvl.Default

    // Status Message handling
    function setDefaultStatusMessage() {
        status_msg_timer.stop();
        status_message = default_status_message;
        status_message_level = default_status_message_level;
    }

    function setStatusMessage(msg, msg_lvl) {
        if(msg === "") {
            return msg;
        }

        let timer_duration_s = 10;
        switch(msg_lvl) {
            case Enums.StatusMsgLvl.Info:
                timer_duration_s = 10;
                break;
            case Enums.StatusMsgLvl.Warn:
                timer_duration_s = 10;
                break;
            case Enums.StatusMsgLvl.Err:
                timer_duration_s = 15;
                break;
        }

        status_message = msg;
        status_message_level = msg_lvl;

        status_msg_timer.interval = timer_duration_s * 1000;
        status_msg_timer.restart();

        return msg;
    }

    Timer
    {
        id: status_msg_timer
        onTriggered: {
            setDefaultStatusMessage();
        }
    }

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

    // Init color theme
    function init_colors() {
        const colors = settings.getThemeColors();

        for(const color of colors) {
            const color_name = color[0];
            const color_value = color[1];
            if(color_name === "" || color_value === "" || color_name === undefined || color_value === undefined) continue;

            rootWindow[color_name] = Qt.color(color_value);
        }
    }

    // Init fonts
    function init_fonts() {
        const fonts = settings.getFonts();

        for(const font of fonts) {
            const font_name = font[0];
            const font_family = font[1];
            const font_size = font[2];
            if(font_name === "" || font_family === "" || font_size === ""
               || font_name === undefined || font_family === undefined || font_size === undefined) continue;

            rootWindow["fontFamily_" + font_name] = font_family;
            rootWindow["fontSize_" + font_name] = font_size;
        }
    }

    // Startup procedure
    Component.onCompleted: {
        database.init_db();

        locale_obj = database.getLocale();

        const db_metadata = database.getDBMetadata();
        db_version = db_metadata[0];

        init_colors();
        init_fonts();

        // Load startup file
        const startup_file_path = database.getLoadOnStartUpPath();
        if(startup_file_path.length > 0) {
            busy_indicator_timer.start();
        }
    }
    Timer
    {
        // Load busy indicator
        id: busy_indicator_timer
        interval: 10
        repeat: false

        onTriggered: {
            busy_loading_indicator_dialog.show();
            open_startup_timer.start();
        }
    }
    Timer
    {
        // Load startup file
        id: open_startup_timer
        interval: 10
        repeat: false

        onTriggered: {
            const msg = setStatusMessage(database.slot_readDB(database.getLoadOnStartUpPath()), Enums.StatusMsgLvl.Err);
            busy_loading_indicator_dialog.close();
            if(msg !== "") return;

            setStatusMessage(qsTr("Opened file"), Enums.StatusMsgLvl.Info);
        }
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
        anchors.topMargin: 2
        anchors.bottomMargin: 1

        onNextFocus: function next_focus(dir) {
            if(dir === Enums.FocusDir.Close) rootWindow.close();
        }
    }

    // Closing handler
    FileCloseDialog 
    {
        id: close_dialog
        function callback_function() { close_okay = true; rootWindow.close(); }
    }
    onClosing: (close) => {
        close.accepted = false;
        close_dialog.init();
        close_dialog.show();

        if(close_okay) close.accepted = true;
    }

    // Shortcuts
    CustomShortcuts
    {
        onShortcutSave: menu_bar.triggerSave();
        onShortcutSaveAs: menu_bar.triggerSaveAs();
        onShortcutNew: menu_bar.triggerNew();
        onShortcutOpen: menu_bar.triggerOpen();
    }

    // Global functions
    function getContrastColor(baseColor) {
        var temp = Qt.darker(baseColor, 1);
        var a = 1 - ( 0.299 * temp.r + 0.587 * temp.g + 0.114 * temp.b);
        return !(temp.a > 0 && a >= 0.3) ? Qt.color("#000000") : Qt.color("#ffffff");
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

    // Busy dialogs
    BusyLoadDialog
    {
        id: busy_loading_indicator_dialog
    }

    BusySaveDialog
    {
        id: busy_saving_indicator_dialog
    }
}