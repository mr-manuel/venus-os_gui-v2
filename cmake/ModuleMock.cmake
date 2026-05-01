qt_add_library(VictronMock STATIC)
qt_add_qml_module(VictronMock
    URI Victron.Mock
    OUTPUT_DIRECTORY Victron/Mock
    QML_FILES ${VictronMock_QML_MODULE_SOURCES}
    ${QML_MODULE_OPTARGS}
)

if (${VENUS_GX_BUILD})
    qt_query_qml_module(VictronMock QML_FILES module_qml_files QMLDIR module_qmldir)
    install(FILES ${module_qmldir} DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Mock)
    install(DIRECTORY data/mock    DESTINATION ${CMAKE_INSTALL_BINDIR}/Victron/Mock/data)
endif()

qt_add_resources(VictronMock "VictronMock_resources"
    BIG_RESOURCES
    FILES ${VictronMock_QML_MODULE_RESOURCES}
)

# Embed example plugin JSON files as resources so they are loadable in mock mode
# (used by guiPluginDirs() fallback for WASM mock and other non-filesystem builds).
if (NOT VENUS_GX_BUILD)
    qt_add_resources(VictronMock "mock_plugin_data"
        BIG_RESOURCES
        PREFIX "/data/mock/plugins"
        BASE "${CMAKE_SOURCE_DIR}/examples/dbus-serialbattery"
        FILES
            "${CMAKE_SOURCE_DIR}/examples/dbus-serialbattery/dbus-serialbattery.json"
    )
endif()

# For desktop builds, also copy the plugin JSON next to the executable so the
# existing <appdir>/plugins/ filesystem path picks it up without a rebuild.
if (VENUS_DESKTOP_BUILD)
    add_custom_command(TARGET VictronMock POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory
            "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/plugins"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_SOURCE_DIR}/examples/dbus-serialbattery/dbus-serialbattery.json"
            "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/plugins/dbus-serialbattery.json"
        COMMENT "Copying dbus-serialbattery mock plugin to ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/plugins/"
    )
endif()

