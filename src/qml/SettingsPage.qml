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

import QRab.settings 1.0


Page {
  id: settingsPage

  property real defaultSpacing: 10

  signal exit(bool accepted)

  RowLayout {
    anchors { fill: parent; margins: defaultSpacing }
    ColumnLayout {
      Layout.fillHeight: true
      anchors {left: parent.left; top: parent.top; bottom: parent.bottom }
      Flickable {
        anchors.fill: parent
        flickableDirection: Flickable.VerticalFlick
        clip: true
        height: leftLay.height

        ColumnLayout {
          id: leftLay
          anchors { fill: parent }

          CheckBox {
            id: copyCheckBox
            checked: QRabSettings.copyToClipboard
            text: qsTr("Copy QR text to clipboard")
            anchors.horizontalCenter: parent.horizontalCenter
          }

          CheckBox {
            id: keepCheckBox
            checked: QRabSettings.keepOnTop
            text: qsTr("Keep QRab window on top")
            anchors.horizontalCenter: parent.horizontalCenter
          }

          RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            Text { text: qsTr("Grab delay") }
            SpinBox {
              id: delaySpinBox
              value: QRabSettings.grabDelay
              from: 0
              to: 2000
              stepSize: 100
            }
          }
            Label {
              text: qsTr("Replace QR text")
              anchors.horizontalCenter: parent.horizontalCenter
            }
            ReplaceList {
              id: replaceList
              replaceTexts: QRabSettings.replaceList
//               interactive: false
              anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; left: parent.left; }
              Layout.fillWidth: true
              Layout.fillHeight: true
            }
        }
      }
    }

    ColumnLayout {
      anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
      Item { Layout.fillHeight: true }
      spacing: font.pixelSize
      Button {
        text: qsTranslate("Qt", "OK") // QPlatformTheme
        onClicked: {
          replaceList.save()
          QRabSettings.copyToClipboard = copyCheckBox.checked
          QRabSettings.grabDelay = delaySpinBox.value
          QRabSettings.keepOnTop = keepCheckBox.checked
          QRabSettings.replaceList = replaceList.replaceTexts
          settingsPage.exit(true)
        }
      }
      Button {
        text: qsTranslate("Qt", "Cancel") // QPlatformTheme
        onClicked: settingsPage.exit(false)
      }
    }
  }

}
