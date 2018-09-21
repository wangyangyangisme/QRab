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
import QtQuick.Window 2.0
import Qt.labs.settings 1.0

import QRab.settings 1.0


ApplicationWindow {
  id: qrabWindow
  visible: true
  title: "QRab"

  property string titleText: "QRab"

  x: settings.x
  y: settings.y
  width: settings.w
  height: settings.h

  SwipeView {
    id: swipeView
    anchors.fill: parent

    currentIndex: 1

    SettingsPage {
      id: settingsPage
      onExit: {
        if (accepted) {
          grabPage.acceptSettings()
          qrabWindow.flags = QRabSettings.keepOnTop ? qrabWindow.flags | Qt.WindowStaysOnTopHint : qrabWindow.flags & ~Qt.WindowStaysOnTopHint
        }
        swipeView.currentIndex = 1
      }
    }

    GrabPage {
      id: grabPage
      onSettingsOn: swipeView.currentIndex = 0
      onAboutOn: swipeView.currentIndex = 2
    }

    AboutPage {
      id: aboutPage
      onExit: swipeView.currentIndex = 1
    }
  }

  Settings {
    id: settings
    category: "Geometry"
    property int x: 1
    property int y: Screen.desktopAvailableHeight * 0.66
    property int w: Screen.desktopAvailableWidth / 3
    property int h: Screen.desktopAvailableHeight / 3
  }

  Component.onCompleted: {
    qrabWindow.flags = QRabSettings.keepOnTop ? qrabWindow.flags | Qt.WindowStaysOnTopHint : qrabWindow.flags
  }

  Component.onDestruction: {
    settings.x = qrabWindow.x
    settings.y = qrabWindow.y
    settings.w = qrabWindow.width
    settings.h = qrabWindow.height
  }
}
