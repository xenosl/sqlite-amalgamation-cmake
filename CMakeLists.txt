cmake_minimum_required(VERSION 3.11)

project(sqlite)

set(sqlite_ARCHIVE sqlite.tar.gz)

file(DOWNLOAD "https://sqlite.org/2023/sqlite-amalgamation-3410200.zip" ${sqlite_ARCHIVE}
        SHOW_PROGRESS
        EXPECTED_HASH SHA3_256=c51ca72411b8453c64e0980be23bc9b9530bdc3ec1513e06fbf022ed0fd02463)

file(ARCHIVE_EXTRACT
        INPUT ${sqlite_ARCHIVE}
        DESTINATION ${CMAKE_BINARY_DIR}/src)


add_definitions(-DSQLITE_ENABLE_RTREE)
add_definitions(-DSQLITE_ENABLE_FTS4)
add_definitions(-DSQLITE_ENABLE_FTS5)
add_definitions(-DSQLITE_ENABLE_JSON1)
add_definitions(-DSQLITE_ENABLE_RBU)
add_definitions(-DSQLITE_ENABLE_STAT4)
#add_definitions(-DSQLITE_THREADSAFE=0)

set(sqlite3_SOURCE_DIR ${CMAKE_BINARY_DIR}/src/sqlite-amalgamation-3410200)

add_library(sqlite3 SHARED)
target_sources(sqlite3
        PRIVATE ${sqlite3_SOURCE_DIR}/sqlite3.c)
target_include_directories(sqlite3
        PUBLIC $<BUILD_INTERFACE:${sqlite3_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)
target_compile_definitions(sqlite3
        PRIVATE "SQLITE_API=__declspec(dllexport)")

add_library(sqlite3-static STATIC)
target_sources(sqlite3-static
        PRIVATE ${sqlite3_SOURCE_DIR}/sqlite3.c)
target_include_directories(sqlite3-static
        PUBLIC $<BUILD_INTERFACE:${sqlite3_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)

add_executable(sqlite3-shell)
target_sources(sqlite3-shell
        PRIVATE ${sqlite3_SOURCE_DIR}/shell.c)
target_include_directories(sqlite3-shell
        PRIVATE ${sqlite3_SOURCE_DIR})
target_link_libraries(sqlite3-shell
        PRIVATE sqlite3-static)
add_dependencies(sqlite3-shell sqlite3-static)

file(STRINGS ${sqlite3_SOURCE_DIR}/sqlite3.h _VER_LINE
        REGEX "^#define SQLITE_VERSION *\"[0-9]+\\.[0-9]+\\.[0-9]+\""
        LIMIT_COUNT 1)
string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+"
        sqlite3_VERSION "${_VER_LINE}")
unset(_VER_LINE)
set_target_properties(sqlite3 sqlite3-static sqlite3-shell
        PROPERTIES VERSION ${sqlite3_VERSION})


include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(sqlite_INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
set(sqlite_PACKAGE_CONFIG_FILE ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake)
set(sqlite_PACKAGE_CONFIG_VERSION_FILE ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake)

install(TARGETS sqlite3 sqlite3-shell
        EXPORT ${PROJECT_NAME}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES ${sqlite3_SOURCE_DIR}/sqlite3.h
        TYPE INCLUDE)

install(EXPORT ${PROJECT_NAME}
        FILE ${PROJECT_NAME}-targets.cmake
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION ${sqlite_INSTALL_DESTINATION})

configure_package_config_file(${PROJECT_SOURCE_DIR}/cmake/${PROJECT_NAME}-config.cmake.in
        ${sqlite_PACKAGE_CONFIG_FILE}
        INSTALL_DESTINATION ${sqlite_INSTALL_DESTINATION})
write_basic_package_version_file(${sqlite_PACKAGE_CONFIG_VERSION_FILE}
        VERSION ${sqlite3_VERSION}
        COMPATIBILITY SameMajorVersion)
install(FILES "${sqlite_PACKAGE_CONFIG_FILE}" "${sqlite_PACKAGE_CONFIG_VERSION_FILE}"
        DESTINATION ${sqlite_INSTALL_DESTINATION})
