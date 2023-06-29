cmake_minimum_required(VERSION 3.11)

project(sqlite)

include(cmake/Utilities.cmake)

# Options
option(DOWNLOAD_SQLITE_ARCHIVE "Whether to automatically download the sqlite3 amalgamation archive." ON)
set(SQLITE_ARCHIVE_URL "https://sqlite.org/2023/sqlite-amalgamation-3410200.zip"
        CACHE STRING "The url of sqlite amalgamation source archive. Only available when DOWNLOAD_SQLITE_ARCHIVE is ON.")
set(SQLITE_ARCHIVE_HASH "c51ca72411b8453c64e0980be23bc9b9530bdc3ec1513e06fbf022ed0fd02463"
        CACHE STRING "The sha2256 hash string for the sqlite amalgamation source archive. Only available when DOWNLOAD_SQLITE_ARCHIVE is ON.")
set(SQLITE_ARCHIVE "${PROJECT_SOURCE_DIR}/sqlite.zip"
        CACHE STRING "Where the sqlite amalgamation source archive located. Set the value locate an existing sqlite
        amalgamation source archive when DOWNLOAD_SQLITE_ARCHIVE is OFF to skip download and let the project use the source
        archive you provided, or specify where the downloaded source archive is located when DOWNLOAD_SQLITE_ARCHIVE is ON.")

if(DOWNLOAD_SQLITE_ARCHIVE)
    file(DOWNLOAD ${SQLITE_ARCHIVE_URL} ${SQLITE_ARCHIVE}
            SHOW_PROGRESS
            EXPECTED_HASH SHA3_256=${SQLITE_ARCHIVE_HASH})
endif()

if(NOT EXISTS ${SQLITE_ARCHIVE})
    message(FATAL_ERROR "Sqlite source archive not found,
     set DOWNLOAD_SQLITE_ARCHIVE to ON to automatically download it or put the file manually to the project source folder.")
endif()

set(SQLITE_ARCHIVE_EXTRACT_DIR ${CMAKE_CURRENT_BINARY_DIR}/src)
file(ARCHIVE_EXTRACT
        INPUT ${SQLITE_ARCHIVE}
        DESTINATION ${SQLITE_ARCHIVE_EXTRACT_DIR})
find_path_recurse(sqlite3_SOURCE_DIR
        NAMES sqlite3.h
        PATHS ${SQLITE_ARCHIVE_EXTRACT_DIR}
        REQUIRED)


add_definitions(-DSQLITE_ENABLE_RTREE)
add_definitions(-DSQLITE_ENABLE_FTS4)
add_definitions(-DSQLITE_ENABLE_FTS5)
add_definitions(-DSQLITE_ENABLE_JSON1)
add_definitions(-DSQLITE_ENABLE_RBU)
add_definitions(-DSQLITE_ENABLE_STAT4)
#add_definitions(-DSQLITE_THREADSAFE=0)

function(set_target_output_directory TARGET DIR)
    set_target_properties(${TARGET} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${DIR}
            LIBRARY_OUTPUT_DIRECTORY ${DIR}
            PDB_OUTPUT_DIRECTORY ${DIR}
            ARCHIVE_OUTPUT_DIRECTORY ${DIR})
endfunction()

add_library(sqlite3 SHARED)
target_sources(sqlite3
        PRIVATE ${sqlite3_SOURCE_DIR}/sqlite3.c)
target_include_directories(sqlite3
        PUBLIC $<BUILD_INTERFACE:${sqlite3_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)
target_compile_definitions(sqlite3
        PRIVATE "SQLITE_API=__declspec(dllexport)")
set_target_output_directory(sqlite3 ${CMAKE_BINARY_DIR}/sqlite3)

add_library(sqlite3-static STATIC)
target_sources(sqlite3-static
        PRIVATE ${sqlite3_SOURCE_DIR}/sqlite3.c)
target_include_directories(sqlite3-static
        PUBLIC $<BUILD_INTERFACE:${sqlite3_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)
set_target_output_directory(sqlite3-static ${CMAKE_BINARY_DIR}/sqlite3-static)

add_executable(sqlite3-shell)
target_sources(sqlite3-shell
        PRIVATE ${sqlite3_SOURCE_DIR}/shell.c)
target_include_directories(sqlite3-shell
        PRIVATE ${sqlite3_SOURCE_DIR})
target_link_libraries(sqlite3-shell
        PRIVATE sqlite3-static)
set_target_output_directory(sqlite3-shell ${CMAKE_BINARY_DIR}/sqlite3-shell)
set_target_properties(sqlite3-shell
        PROPERTIES RUNTIME_OUTPUT_NAME sqlite3)
add_dependencies(sqlite3-shell sqlite3-static)

file(STRINGS ${sqlite3_SOURCE_DIR}/sqlite3.h _VER_LINE
        REGEX "^#define SQLITE_VERSION *\"[0-9]+\\.[0-9]+\\.[0-9]+\""
        LIMIT_COUNT 1)
string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+"
        sqlite3_VERSION "${_VER_LINE}")
unset(_VER_LINE)
set_target_properties(sqlite3 sqlite3-static sqlite3-shell
        PROPERTIES VERSION ${sqlite3_VERSION})
message(STATUS "sqlite3 version: ${sqlite3_VERSION}")


include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(sqlite_INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
set(sqlite_PACKAGE_CONFIG_FILE ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config.cmake)
set(sqlite_PACKAGE_CONFIG_VERSION_FILE ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake)

install(TARGETS sqlite3 sqlite3-static sqlite3-shell
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
