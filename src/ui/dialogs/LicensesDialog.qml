import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtPositioning
import QtQuick.Controls.Basic

import "../components"
import "../types"

ApplicationWindow
{
    id: dialog
    title: qsTr("Licenses") + " - " + qsTr("Organization Data Management")
    color: backgroundColor1
    modality: Qt.ApplicationModal
    minimumWidth: 300
    minimumHeight: 200
    width: 500
    height: 300

    CustomShortcuts
    {
        id: custom_shortcuts

        shortcutCloseEnabled: true
        onShortcutClose: {
            dialog.close();
        }
    }

    function init() {
        // Call this function before .show()
        let res = "";

        res += "# " + qsTr("Images");
        res += "  \n";
        res += "**" + qsTr("Window Icon") + "**: *mcmurryjulie* - " + "https://pixabay.com/de/vectors/datenbank-suche-2797375/";
        res += "  \n";
        res += "**" + qsTr("Checkmark") + "**: *janjf93* - " + "https://pixabay.com/de/vectors/haken-h%C3%A4kchen-check-abgeschlossen-1727484/";
        res += "  \n";
        res += "**" + qsTr("Error mark") + "**: *janjf93* - " + "https://pixabay.com/de/vectors/falsch-fehler-fehlt-fehlend-error-2061132/";
        res += "  \n";
        res += "**" + qsTr("Paper icon") + "**: *OpenClipart-Vectors* - " + "https://pixabay.com/de/vectors/datei-papier-dokumentieren-leer-151104/";
        res += "  \n";
        res += "**" + qsTr("Folder icon") + "**: *janjf93* - " + "https://pixabay.com/de/vectors/ordner-flach-design-icon-symbol-2103508/";
        res += "  \n";
        res += "**" + qsTr("Save & Save As icon") + "**: *everton_ribas* - " + "https://pixabay.com/de/vectors/icon-pack-paket-symbole-speichern-2129743/";
        res += "  \n";
        res += "**" + qsTr("Exit symbol") + "**: *janjf93* - " + "https://pixabay.com/de/vectors/ausgang-ende-exit-notausgang-t%C3%BCr-1699614/";
        res += "  \n";
        res += "**" + qsTr("Globe icon") + "**: *Lucek* - " + "https://pixabay.com/de/vectors/internet-symbol-netz-unterzeichnen-3383600/";
        res += "  \n";
        res += "**" + qsTr("Link icon") + "**: *mcmurryjulie* - " + "https://pixabay.com/de/vectors/broken-link-link-rot-2367103/";
        res += "  \n";
        res += "**" + qsTr("Note") + "**: *" + qsTr("Some of the images were modified.") + "*";
        res += "  \n\n  ---  \n";

        res += "# " + qsTr("Qt6.6 & QML");
        res += "  \n";
        res += "*Qt is available under the GNU Lesser General Public License version 3.*";
        res += "  \n";
        res += "**" + qsTr("Reference") + "**: " + "http://www.gnu.org/licenses/lgpl-3.0.html";
        res += "  \n";
        res += "## " + "LGPL version 3";
        res += "  \n";
        res += getQtLicense();
        res += "  \n";

        licenses_text.text = res;
    }

    Column
    {
        width: parent.width
        height: parent.height
        anchors.fill: parent
        spacing: 4
        property int row_count: 2

        Rectangle
        {
            id: headline_rect
            width: parent.width
            height: Math.min((parent.height - (parent.spacing * parent.row_count)) * 0.15, 43.8)
            color: backgroundColor2
            focus: true

            Row
            {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 8

                Text
                {
                    id: title_text
                    width: (parent.width - parent.spacing) * 0.3
                    height: parent.height
                    text: qsTr("Licenses")
                    font.pointSize: fontSize_big
                    font.family: fontFamily_big
                    color: textColor
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font.bold: true
                }

                Text
                {
                    id: title_text_description
                    width: (parent.width - parent.spacing) * 0.7
                    height: parent.height
                    text: qsTr("Organization Data Management")
                    font.pointSize: fontSize_big
                    font.family: fontFamily_big
                    color: textColor1
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        ScrollView
        {
            id: licenses_text_scroll_view
            height: (parent.height - (parent.spacing * parent.row_count)) - headline_rect.height
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            contentWidth: licenses_text_scroll_view.width
            contentHeight: licenses_text.height

            Text
            {
                id: licenses_text
                text: ""
                width: licenses_text_scroll_view.width
                font.pointSize: fontSize_default
                font.family: fontFamily_default
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                lineHeight: 1.3
                wrapMode: Text.Wrap
                textFormat: Text.MarkdownText
            }
        }
    }

    function getQtLicense() {
        return String.raw`GNU LESSER GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

  This version of the GNU Lesser General Public License incorporates
the terms and conditions of version 3 of the GNU General Public
License, supplemented by the additional permissions listed below.

  0. Additional Definitions.

  As used herein, "this License" refers to version 3 of the GNU Lesser
General Public License, and the "GNU GPL" refers to version 3 of the GNU
General Public License.

  "The Library" refers to a covered work governed by this License,
other than an Application or a Combined Work as defined below.

  An "Application" is any work that makes use of an interface provided
by the Library, but which is not otherwise based on the Library.
Defining a subclass of a class defined by the Library is deemed a mode
of using an interface provided by the Library.

  A "Combined Work" is a work produced by combining or linking an
Application with the Library.  The particular version of the Library
with which the Combined Work was made is also called the "Linked
Version".

  The "Minimal Corresponding Source" for a Combined Work means the
Corresponding Source for the Combined Work, excluding any source code
for portions of the Combined Work that, considered in isolation, are
based on the Application, and not on the Linked Version.

  The "Corresponding Application Code" for a Combined Work means the
object code and/or source code for the Application, including any data
and utility programs needed for reproducing the Combined Work from the
Application, but excluding the System Libraries of the Combined Work.

  1. Exception to Section 3 of the GNU GPL.

  You may convey a covered work under sections 3 and 4 of this License
without being bound by section 3 of the GNU GPL.

  2. Conveying Modified Versions.

  If you modify a copy of the Library, and, in your modifications, a
facility refers to a function or data to be supplied by an Application
that uses the facility (other than as an argument passed when the
facility is invoked), then you may convey a copy of the modified
version:

   a) under this License, provided that you make a good faith effort to
   ensure that, in the event an Application does not supply the
   function or data, the facility still operates, and performs
   whatever part of its purpose remains meaningful, or

   b) under the GNU GPL, with none of the additional permissions of
   this License applicable to that copy.

  3. Object Code Incorporating Material from Library Header Files.

  The object code form of an Application may incorporate material from
a header file that is part of the Library.  You may convey such object
code under terms of your choice, provided that, if the incorporated
material is not limited to numerical parameters, data structure
layouts and accessors, or small macros, inline functions and templates
(ten or fewer lines in length), you do both of the following:

   a) Give prominent notice with each copy of the object code that the
   Library is used in it and that the Library and its use are
   covered by this License.

   b) Accompany the object code with a copy of the GNU GPL and this license
   document.

  4. Combined Works.

  You may convey a Combined Work under terms of your choice that,
taken together, effectively do not restrict modification of the
portions of the Library contained in the Combined Work and reverse
engineering for debugging such modifications, if you also do each of
the following:

   a) Give prominent notice with each copy of the Combined Work that
   the Library is used in it and that the Library and its use are
   covered by this License.

   b) Accompany the Combined Work with a copy of the GNU GPL and this license
   document.

   c) For a Combined Work that displays copyright notices during
   execution, include the copyright notice for the Library among
   these notices, as well as a reference directing the user to the
   copies of the GNU GPL and this license document.

   d) Do one of the following:

       0) Convey the Minimal Corresponding Source under the terms of this
       License, and the Corresponding Application Code in a form
       suitable for, and under terms that permit, the user to
       recombine or relink the Application with a modified version of
       the Linked Version to produce a modified Combined Work, in the
       manner specified by section 6 of the GNU GPL for conveying
       Corresponding Source.

       1) Use a suitable shared library mechanism for linking with the
       Library.  A suitable mechanism is one that (a) uses at run time
       a copy of the Library already present on the user's computer
       system, and (b) will operate properly with a modified version
       of the Library that is interface-compatible with the Linked
       Version.

   e) Provide Installation Information, but only if you would otherwise
   be required to provide such information under section 6 of the
   GNU GPL, and only to the extent that such information is
   necessary to install and execute a modified version of the
   Combined Work produced by recombining or relinking the
   Application with a modified version of the Linked Version. (If
   you use option 4d0, the Installation Information must accompany
   the Minimal Corresponding Source and Corresponding Application
   Code. If you use option 4d1, you must provide the Installation
   Information in the manner specified by section 6 of the GNU GPL
   for conveying Corresponding Source.)

  5. Combined Libraries.

  You may place library facilities that are a work based on the
Library side by side in a single library together with other library
facilities that are not Applications and are not covered by this
License, and convey such a combined library under terms of your
choice, if you do both of the following:

   a) Accompany the combined library with a copy of the same work based
   on the Library, uncombined with any other library facilities,
   conveyed under the terms of this License.

   b) Give prominent notice with the combined library that part of it
   is a work based on the Library, and explaining where to find the
   accompanying uncombined form of the same work.

  6. Revised Versions of the GNU Lesser General Public License.

  The Free Software Foundation may publish revised and/or new versions
of the GNU Lesser General Public License from time to time. Such new
versions will be similar in spirit to the present version, but may
differ in detail to address new problems or concerns.

  Each version is given a distinguishing version number. If the
Library as you received it specifies that a certain numbered version
of the GNU Lesser General Public License "or any later version"
applies to it, you have the option of following the terms and
conditions either of that published version or of any later version
published by the Free Software Foundation. If the Library as you
received it does not specify a version number of the GNU Lesser
General Public License, you may choose any version of the GNU Lesser
General Public License ever published by the Free Software Foundation.

  If the Library as you received it specifies that a proxy can decide
whether future versions of the GNU Lesser General Public License shall
apply, that proxy's public statement of acceptance of any version is
permanent authorization for you to choose that version for the
Library.`;
    }
}