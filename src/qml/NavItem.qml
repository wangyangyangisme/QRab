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
import QtQuick.Layouts 1.3


Item {
  id: navItem

  property alias iconFile: icon.source
  property alias text: caption.text

  property int iconSize: font.pixelSize * 5
  property color bgColor: palette.window

  height: font.pixelSize * 7
  width: font.pixelSize * 6

  signal clicked()

  SystemPalette {
    id: palette;
    colorGroup: SystemPalette.Active
  }

//   Rectangle {
//     id: bgRect
//     anchors.fill: parent
//     color: palette.shadow
//     width: font.pixelSize * 5.3
//     height: font.pixelSize * 5.3
//     anchors.horizontalCenter: parent.horizontalCenter
//   }

  ColumnLayout {
    width: navItem.width

    Image {
      id: icon
      source: iconFile
      sourceSize.height: iconSize
      sourceSize.width: iconSize
      anchors.horizontalCenter: parent.horizontalCenter
    }
    Text {
      id: caption
      text: text
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      bgColor = palette.highlight
      navItem.clicked()
    }
  }
}
