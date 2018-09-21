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
import QtQuick.Window 2.0


Dialog {
  id: adjustDialog
  visible: true
  title: qsTr("Adjust sheet")
  width: Screen.desktopAvailableWidth / 2
  height: Screen.desktopAvailableHeight / 2

  property var itemList: [] // list of delegate items

  signal adjusted(var keyList)

  contentItem: ColumnLayout { // this way, dialog button are hidden, we are shopping our own buttons
    anchors.fill: parent
    anchors.margins: 10

    ListView {
      id: sheetList
      clip: true
      Layout.fillWidth: true
      Layout.fillHeight: true

      Component {
        id: delegate

        Item {
          id: delegateItem
          height: sheetCol.height
          width: sheetList.width
          property color textColor: activePal.text

          Rectangle {
            id: bgRect
            anchors.fill: parent
            color: index % 2 === 1 ? activePal.alternateBase : activePal.base
          }

          Row {
            spacing: font.pixelSize
            Layout.fillWidth: true
            anchors.right: parent.right

            Text {
              id: qrRowText
              text: qrChunk
              wrapMode: Text.Wrap
              color: rowEnabled.checked ? activePal.text : disabledPal.text
              anchors.verticalCenter: parent.verticalCenter
            }
            TextField {
              id: sheetCol
              maximumLength: 2
              width: font.pixelSize * 3
              enabled: rowEnabled.checked
              text: cell
              color: delegateItem.textColor
              horizontalAlignment: TextInput.AlignHCenter
              validator: RegExpValidator { regExp: /[A-Z]|[A-Z][A-Z]/ }
              onTextChanged: {
                sheetModel.set(index, { "cell": sheetCol.text })
                textColor = activePal.text
              }
            }
            CheckBox {
              id: rowEnabled
              checked: use
              onCheckedChanged: sheetModel.set(index, { "use": rowEnabled.checked })
            }
          }
          Component.onCompleted: itemList.push(delegateItem)
        }
      }

      model: ListModel {
        id: sheetModel
//         ListElement {
//           qrChunk: ""
//           cell: "B"
//           use: true
//         }
      }
      delegate: delegate
    }

    RowLayout {
      anchors.margins: 10
      spacing: 10
      Button {
        id: resetButt
        text: qsTr("Reset")
        onClicked: {
          for (var i = 0; i < sheetModel.count; ++i) {
            sheetModel.set(i, { "cell": columnLetter(i), "use": true })
            itemList[i].textColor = activePal.text
          }
        }
      }
      Item { Layout.fillWidth: true }
      Button {
        id: cancelButt
        text: qsTr("Cancel")
        onClicked: adjustDialog.destroy()
      }
      Button {
        id: applyButt
        text: qsTr("Apply")
        onClicked: {
            if (!verify()) {
              sameColumnsMess.open()
              return
            }

            var keyL = []
            for (var i = 0; i < sheetModel.count; ++i) {
              var model = sheetModel.get(i)
              if (model.use) {
                  keyL.push(cellNumber(model.cell))
//                   console.log(model.cell + "->" + keyL[i])
              } else
                  keyL.push(0)
            }
            adjusted(keyL)
            close()
            adjustDialog.destroy()
        }
      }
    }
    Item { height: 10 } // Bottom spacer
  }

  SystemPalette { id: activePal; colorGroup: SystemPalette.Active }
  SystemPalette { id: disabledPal; colorGroup: SystemPalette.Inactive }

  MessageDialog {
    id: sameColumnsMess
    title: "QRab"
    text: qsTr("Multiple columns with the same letter!")
  }

  /**
   * Loads QR text @p qr into model.
   * When @p cells is set, changes appropriate column letters
   */
  function loadQRtext(qr, cells) {
    if (qr.indexOf("\t") === -1)
      return false

    var s = qr.split("\t")
    for (var i = 0; i < s.length; ++i) {
      var letterId = i
      var colUse = true
      if (cells && i < cells.length) {
        if (cells[i] > 0)
          letterId = cells[i] - 1
        else
          colUse = false
      }
      var model = { "qrChunk": s[i], "cell": columnLetter(letterId), "use": colUse }
      if (i < sheetModel.count) {
          sheetModel.set(i, model)
      } else {
          sheetModel.append(model)
      }
    }
    return true
  }

    /** Converts given column letter(s) into number, i.e. A->1, B->2, AA->26 etc. */
  function cellNumber(cellStr) {
    var first = cellStr.charCodeAt(0) - 64
    if (cellStr.length === 1)
      return first
    else
      return first * 26 + cellStr.charCodeAt(1) - 64
  }

    /**
     * Converts given number into letter(s) singing spreadsheet column,
     * reverse to @p cellNumber() function
     * !!!!! BUT 0->A, 1->B, etc. !!!!!
     */
  function columnLetter(nr) {
    if (nr == 0)
      return "A"
    if (nr < 26)
      return String.fromCharCode(nr + 65)
    return String.fromCharCode(nr / 26 + 64) + String.fromCharCode(nr % 26 + 65);
  }

  function verify() {
    var ok = true
    for (var i = 0; i < sheetModel.count; ++i) {
      var iItem = sheetModel.get(i)
      if (!iItem.use) // ignore disabled
        continue
      var colLetter = iItem.cell
      for (var j = i + 1; j < sheetModel.count; ++j) {
        var jItem = sheetModel.get(j)
        if (!jItem.use)
          continue
        if (colLetter === jItem.cell) {
            itemList[i].textColor = "red"
            itemList[j].textColor = "red"
            ok = false
        }
      }
    }
    return ok
  }

}
