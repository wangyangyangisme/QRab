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
import QtQuick.Dialogs 1.2

import TgrabQR 1.0
import QRab.settings 1.0


Page {
  id: grabPage

  property real defaultSpacing: 10

  signal settingsOn()
  signal aboutOn()

  TgrabQR {
    id: qr
    Component.onCompleted: {
      grabPage.acceptSettings()
      qr.setCells(QRabSettings.cells)
    }
  }

  function acceptSettings() {
    qr.copyToClipboard = QRabSettings.copyToClipboard
    qr.grabDelay = QRabSettings.grabDelay
    if (QRabSettings.replaceList)
      qr.replaceList = QRabSettings.replaceList
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: defaultSpacing

    RowLayout {
      Button {
        id: settingsButt
        text: qsTr("Settings")
        onClicked: grabPage.settingsOn()
      }

      Item { Layout.fillWidth: true }

      Button {
        id: aboutButt
        text: qsTr("About")
        onClicked: grabPage.aboutOn()
      }
    }
    Flickable {
      id: flickText
      Layout.fillHeight: true
      Layout.fillWidth: true
      flickableDirection: Flickable.VerticalFlick
      contentWidth: qrText.paintedWidth
      contentHeight: qrText.paintedHeight
      clip: true

      function ensureVisible(r) {
          if (contentX >= r.x)
              contentX = r.x;
          else if (contentX+width <= r.x+r.width)
              contentX = r.x+r.width-width;
          if (contentY >= r.y)
              contentY = r.y;
          else if (contentY+height <= r.y+r.height)
              contentY = r.y+r.height-height;
       }

      TextEdit {
        id: qrText
        textFormat: Text.RichText
        text: "<b><center style=\"font-size: xx-large\">" + qsTr("Put any QR code on a screen,<br>then hit GRAB! button") + "</center></b>"
        focus: true
        width: flickText.width
        height: flickText.height
        wrapMode: TextArea.Wrap
        readOnly: true
        onCursorRectangleChanged: flickText.ensureVisible(cursorRectangle)

        Connections {
          target: qr
          onGrabDone: {
            var str = qr.qrText
            if (str == "") {
                qrText.textFormat = Text.RichText
                qrText.text = "<b><center style=\"color: red; font-size: xx-large\">" + qsTr("No QR code found!") + "</center></b>"
                adjustButt.visible = false
                qrRadio.visible = false
                clipRadio.visible = false
            } else {
                qrText.textFormat = Text.PlainText
                qrText.text = str
                adjustButt.visible = true
                qrRadio.visible = true
                clipRadio.visible = true
            }
          }
        }
      }
    }

    RowLayout {
      Button {
        id: adjustButt
        text: qsTr("Adjust sheet")
        visible: false
        onClicked: {
          var c = Qt.createComponent("qrc:/AdjustDialog.qml")
          var a = c.createObject(grabPage)
          if (a.loadQRtext(qr.replacedText, QRabSettings.cells))
              a.adjusted.connect(adjustAccepted)
          else {
              noTabMess.open()
              a.destroy()
          }
        }
        function adjustAccepted(keyList) {
          qr.setCells(keyList)
          QRabSettings.cells = keyList
        }
      }
      Item { Layout.fillWidth: true }
      RadioButton {
        id: qrRadio
        text: qsTr("QR text")
        checked: true
        visible: false
      }
      RadioButton {
        id: clipRadio
        text: qsTr("Clipboard text")
        visible: false
      }
      Item { Layout.fillWidth: true }
      Button {
        id: qrabButt
        text: qsTr("GRAB!")
        onClicked: {
          qr.grab()
        }
      }
    }
  }

  ButtonGroup {
    id: gr
    buttons: [qrRadio, clipRadio]
    onCheckedButtonChanged: {
      if (adjustButt.visible) { // ignore when no QR text was found or at very beginning
        if (gr.checkedButton == qrRadio)
          qrText.text = qr.qrText
        else
          qrText.text = qr.clipText
      }
    }
  }

  MessageDialog {
    id: noTabMess
    title: "QRab"
    text: qsTr("There is no tabulators in the text.
It can not be split into spreadsheet columns.
To add tabulators, you may use find->replace settings.")
  }
}




