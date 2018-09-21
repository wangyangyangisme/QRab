cmake_minimum_required(VERSION 3.1.0)

project(qrab)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt5Gui REQUIRED)
if (Qt5Gui_FOUND)
    if (Qt5Gui_VERSION VERSION_LESS 5.7.0)
        message(FATAL_ERROR "Minimum supported Qt5 version is 5.7.0")
    endif()
else()
    message(SEND_ERROR "The Qt5Gui library could not be found!")
endif(Qt5Gui_FOUND)


find_package(Qt5Qml REQUIRED)
find_package(Qt5Quick REQUIRED)
find_package(Qt5QuickControls2 REQUIRED)


set(QRAB_VERSION_MAJOR  "0")
set(QRAB_VERSION_MINOR  "3")
set(QRAB_VERSION "${QRAB_VERSION_MAJOR}.${QRAB_VERSION_MINOR}")


# Looking for zbar
if(ZBAR_LIBRARIES AND ZBAR_INCLUDE_DIRS)
    set(ZBAR_FOUND TRUE)
else(ZBAR_LIBRARIES AND ZBAR_INCLUDE_DIRS)
    find_path(ZBAR_INCLUDE_DIR
          NAMES
            zbar.h
          PATHS
            /usr/include
            /usr/local/include
            /opt/local/include
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}../zbar/include
            ${CMAKE_BINARY_DIR}/../zbar/include
        )

    find_library(ZBAR_LIBRARY
          NAMES
            zbar
          PATHS
            /usr/lib
            /usr/lib64
            /usr/local/lib
            /opt/local/lib
            /sw/lib
            ${CMAKE_BINARY_DIR}/../zbar
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}../zbar
    )

    set(ZBAR_INCLUDE_DIRS
      ${ZBAR_INCLUDE_DIR}
    )
    set(ZBAR_LIBRARIES
      ${ZBAR_LIBRARY}
    )

    if(ZBAR_INCLUDE_DIRS AND ZBAR_LIBRARIES)
      set(ZBAR_FOUND TRUE)
    endif(ZBAR_INCLUDE_DIRS AND ZBAR_LIBRARIES)

    if(ZBAR_FOUND)
        message(STATUS "ZBAR library was found in: ${ZBAR_LIBRARIES}, its headers are in: ${ZBAR_INCLUDE_DIRS}")
        if(WIN32 OR APPLE)
          include_directories( ${ZBAR_INCLUDE_DIRS} )
        endif(WIN32 OR APPLE)
    else(ZBAR_FOUND)
        message(FATAL_ERROR "Could not find zbar\nTry call cmake with args:\n-DZBAR_LIBRARIES=/path_to/libzbar.la(dll) -DZBAR_INCLUDE_DIRS=/path_to_dir_with/include/zbar.h\nor put those files into zbar directory on the level of sources")
    endif(ZBAR_FOUND)

endif(ZBAR_LIBRARIES AND ZBAR_INCLUDE_DIRS)


if (APPLE) # Mac RPath
  set(CMAKE_MACOSX_RPATH 1)
  set(CMAKE_INSTALL_RPATH "@loader_path/../Frameworks")
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
endif (APPLE)



set(qrab_SRC
  src/main.cpp
  src/tgrabqr.cpp
)


if(MINGW)
    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/qrabico.o
                       COMMAND windres.exe -I${CMAKE_CURRENT_SOURCE_DIR} -i${CMAKE_CURRENT_SOURCE_DIR}/icons/qrab-icon.rc
                            -o ${CMAKE_CURRENT_BINARY_DIR}/qrabico.o )
    set(qrab_SRCS ${qrab_SRC} ${CMAKE_CURRENT_BINARY_DIR}/qrabico.o)
    set(qrab_EXE_ICON qrabico.o)
endif(MINGW)


qt5_add_resources(qrab_SRC qrab.qrc)


add_executable(qrab WIN32 ${qrab_SRC} ${qrab_EXE_ICON})


target_link_libraries(qrab 
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    ${ZBAR_LIBRARY}
)

if(UNIX AND NOT APPLE)
    install(TARGETS qrab DESTINATION bin)
    install(FILES icons/qrab.png DESTINATION share/pixmaps)
    install(FILES icons/qrab.desktop DESTINATION share/applications)
else()
  get_target_property(QtCore_location_Release Qt5::Core LOCATION_Release)
  get_filename_component(QT_BINARY_DIR "${QtCore_location_Release}" DIRECTORY)
  if(WIN32)
    install(TARGETS qrab DESTINATION .)
    add_custom_target(deploy
      COMMAND echo "deploying..."
      COMMAND ${QT_BINARY_DIR}/windeployqt.exe --release --no-translations --no-svg --no-widgets --qmldir "${CMAKE_SOURCE_DIR}/src/qml"  "${CMAKE_INSTALL_PREFIX}/qrab.exe"
    )
  else()
    install(TARGETS qrab DESTINATION "${CMAKE_INSTALL_PREFIX}/qrab.app/Contents/MacOs")
    install(FILES "${CMAKE_SOURCE_DIR}/icons/qrab.icns" DESTINATION "${CMAKE_INSTALL_PREFIX}/qrab.app/Contents/Resources")
    install(FILES "${CMAKE_SOURCE_DIR}/icons/info.plist" DESTINATION "${CMAKE_INSTALL_PREFIX}/qrab.app/Contents")
    add_custom_target(deploy
      COMMAND echo "deploying..."
      COMMAND echo ${QT_BINARY_DIR}/../../bin
      COMMAND ${QT_BINARY_DIR}/../../bin/macdeployqt ${CMAKE_INSTALL_PREFIX}/qrab.app -qmldir="${CMAKE_SOURCE_DIR}/src/qml"
    )
  endif(WIN32)
endif(UNIX AND NOT APPLE)


if(UNIX AND NOT APPLE)
    message(STATUS "
    To build source package, call:
    make src
    ")
    add_custom_target(src COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/make-src.sh ${QRAB_VERSION} ${CMAKE_BINARY_DIR} ${CMAKE_SOURCE_DIR})
ENDIF(UNIX AND NOT APPLE)



configure_file(
     "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
     "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
        IMMEDIATE @ONLY)

  add_custom_target(uninstall
   COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
)
