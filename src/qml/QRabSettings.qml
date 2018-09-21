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

pragma Singleton
import QtQuick 2.7
import Qt.labs.settings 1.0


/**
 * Single instance object with all QRab settings
 * shared between other objects
 * Due to bug in Qt string list has to be merged before storing
 * Magic separator for it is defined in @p splitString "&|$"
 */
Item {
  property int grabDelay
  property bool copyToClipboard
  property bool keepOnTop
  property var replaceList
  property string concatList
  property var cells
  property string concatCells
  default property string splitString: "&|$"

  onConcatListChanged: replaceList = concatList.split(splitString)
  onConcatCellsChanged: {
    if (concatCells !== "")
      cells =  concatCells.split(splitString)
  }

  Settings {
    id: settings
    category: "QRab"
    property bool copyToClipboard: true
    property bool keepOnTop: true
    property int grabDelay: 100
    property var concatList: "\n" + splitString + "\t"
    property string concatCells: ""
  }

  Component.onCompleted: {
    grabDelay = settings.grabDelay
    copyToClipboard = settings.copyToClipboard
    keepOnTop = settings.keepOnTop
    concatList = settings.concatList
    concatCells = settings.concatCells
  }

  Component.onDestruction: {
    settings.grabDelay = grabDelay
    settings.copyToClipboard = copyToClipboard
    settings.keepOnTop = keepOnTop
    if (replaceList)
      settings.concatList = replaceList.join(splitString)
    if (cells)
      settings.concatCells = cells.join(splitString)
  }
}

