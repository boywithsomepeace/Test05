cmake_minimum_required(VERSION 3.21)
project(EvHmi
    VERSION 0.1.0
    LANGUAGES CXX
)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOMOC_COMPILER_PREDEFINES OFF)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
include(GNUInstallDirs)
set_source_files_properties(
    qml/themes/Colors.qml
    qml/themes/Typography.qml
    qml/themes/Theme.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)
qt_add_executable(ev_hmi
    main.cpp
    backend/SettingsManager.cpp
    backend/SettingsManager.h
    backend/VehicleDataManager.cpp
    backend/VehicleDataManager.h
    models/VehicleTelemetry.h
    simulations/TelemetrySimulator.cpp
    simulations/TelemetrySimulator.h
)
target_include_directories(ev_hmi
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)
qt_add_qml_module(ev_hmi
    URI EvHmi
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/AppShell.qml
        qml/components/BaseCard.qml
        qml/components/CockpitFrame.qml
        qml/components/EnergyBar.qml
        qml/components/MetricTile.qml
        qml/components/GraphCard.qml
        qml/components/MediaCard.qml
        qml/components/ModeButton.qml
        qml/pages/HomePage.qml
        qml/pages/MusicPage.qml
        qml/pages/SettingsPage.qml
        qml/pages/DiagnosticsPage.qml
        qml/themes/Colors.qml
        qml/themes/Typography.qml
        qml/themes/Theme.qml
)
target_link_libraries(ev_hmi
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)

qt_add_resources(ev_hmi ev_hmi_i18n
    PREFIX "/"
    FILES
        i18n/ev_hmi_de.ts
        i18n/ev_hmi_es.ts
)
if (UNIX AND NOT APPLE)
    install(TARGETS ev_hmi
        BUNDLE DESTINATION .
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endif()
