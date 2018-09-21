/***************************************************************************
 *   Copyright (C) 2016 by Tomasz Bojczuk                                  *
 *   seelook@gmail.com                                                     *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License	     *
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.  *
 ***************************************************************************/

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3


Page {
  id: aboutPage

  property real defaultSpacing: 10

  signal exit()

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: defaultSpacing

    RowLayout {
      Flickable {
        id: pageSwitch
        Layout.fillHeight: true
        width: font.pixelSize * 6
        clip: true
        flickableDirection: Flickable.VerticalFlick

        Rectangle {
          anchors.fill: parent
//           border.width: 1
        }

        ColumnLayout {
          anchors.fill: parent

          Item { height: font.pixelSize / 2 }
          NavItem {
            id: aboutId
            iconFile: "qrc:/icons/about.png"
            text: qsTranslate("GrabPage", "About")
            onClicked: stackLay.currentIndex = 0
          }
          NavItem {
            id: licenseId
            iconFile: "qrc:/icons/license.png"
            text: qsTr("License")
            onClicked: stackLay.currentIndex = 1
          }
          Item { Layout.fillHeight: true }
        }
      }

      StackLayout {
        id: stackLay
        ColumnLayout { // FIRST page with info about QRab
          Layout.fillWidth: true
          anchors.horizontalCenter: parent.horizontalCenter

          RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
              source: "qrc:/icons/qrab-image.png"
              sourceSize.height: font.pixelSize * 7
            }
            ColumnLayout {
              Text {
                text: "  QRab 0.3"
                font.bold: true
                Component.onCompleted: font.pixelSize = font.pixelSize * 2
              }
              LinkText { text: " <a href=\"https://qrab.sourceforge.io\">https://qrab.sourceforge.io</a>" }
            }
          }
          Text {
            text: qsTr("Grabs QR code contexts from your screen")
            anchors.horizontalCenter: parent.horizontalCenter
          }
          RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            Text { text: qsTr("Author:") }
            LinkText {
              text: " Tomasz Bojczuk <a href=\"mailto:seelook.gmail.com\">seelook@gmail.com</a>"
              font.bold: true
            }
          }
          Text {
            text: qsTr("On the terms of GNU GPLv3 license.") 
            anchors.horizontalCenter: parent.horizontalCenter
          }
          LinkText {
            text: qsTr("QRab uses %1 to handle QR codes.<br>Zbar is delivering on GNU LGPLv2.1 license.").arg("<b><a href=\"http://zbar.sf.net\">zbar</a></b>")
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
          }
          Item { Layout.fillHeight: true } // a spacer
        }
        Flickable {
          Layout.fillHeight: true
          clip: true
          flickableDirection: Flickable.VerticalFlick
          contentWidth: secondPage.width
          contentHeight: secondPage.height
          ColumnLayout { // SECOND page with license text
            id: secondPage
            Label {
              text: qsTr("QRab
Copyright (C) 2016  Tomasz Bojczuk
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA"
                    )
              horizontalAlignment: Text.AlignJustify
            }
            LinkText {
              text: "<a href=\"https://www.gnu.org/licenses/gpl-3.0.html\">https://www.gnu.org/licenses/gpl-3.0.html</a>"
              anchors.horizontalCenter: parent.horizontalCenter
              font.bold: true
            }
            Item { height: aboutPage.font.pixelSize * 3 }
          }
        }
      }
    }
    RowLayout {
      Item { Layout.fillWidth: true }
      Button {
        text: qsTranslate("Qt", "OK") // QPlatformTheme context
        onClicked: aboutPage.exit()
      }
    }
  }
}

