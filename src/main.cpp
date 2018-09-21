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

#include "tgrabqr.h"
#include <QtCore/QTranslator>
#include <QtCore/QLibraryInfo>
#include <QtCore/QDir>
#include <QtCore/QDebug>
#include <QtGui/QGuiApplication>
#include <QtGui/QIcon>
#include <QtQml/QQmlApplicationEngine>
// #include <QtQuickControls2/QQuickStyle>


int main(int argc, char *argv[])
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QGuiApplication a(argc, argv);

  QCoreApplication::setOrganizationName("QRab");
  QCoreApplication::setOrganizationDomain("qrab.sf.net");

  a.setWindowIcon(QIcon(QStringLiteral(":/icons/qrab.png")));

// Loading translations
  QTranslator qrabTranslator;

#if defined (Q_OS_MAC)
  QLocale loc(QLocale::system().uiLanguages().first());
#else
  QLocale loc(qgetenv("LANG"));
#endif
  QLocale::setDefault(loc);

  if (qrabTranslator.load(loc, QStringLiteral("qrab_"), QString(), QStringLiteral(":/lang")))
    a.installTranslator(&qrabTranslator);


  qmlRegisterType<TgrabQR>("TgrabQR", 1, 0, "TgrabQR");
  qmlRegisterSingletonType(QUrl("qrc:/QRabSettings.qml"), "QRab.settings", 1, 0, "QRabSettings");

//   QQuickStyle::setStyle(QStringLiteral("Material"));

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

  return a.exec();
}

