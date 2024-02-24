import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning

import "../components"
import "../types"

TemplateDialog
{
    id: dialog

    title_text: qsTr("Do you want to proceed?")
    main_text: qsTr("All unsaved changes will be lost.")
    sub_text: qsTr("Do you want to proceed?")
    ok_text: qsTr("Proceed")
    abort_text: qsTr("Abort")
}