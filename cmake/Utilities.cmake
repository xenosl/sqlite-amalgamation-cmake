
# Find containing directory of specified file with certain names.
function(find_path_recurse VAR)
    cmake_parse_arguments("ARG" # Variable prefix
            "REQUIRED" # Options
            "" # One-Value arguments
            "NAMES;PATHS" # Multi-Value arguments
            ${ARGN})

    if(NOT ARG_NAMES)
        message(FATAL_ERROR "File name for finding not specified.")
    endif()
    if(NOT ARG_PATHS)
        message(FATAL_ERROR "Root paths for finding not specified.")
    endif()

    foreach(PATH ${ARG_PATHS})
        file(GLOB_RECURSE FILES ${PATH}/*)
        foreach(FILE ${FILES})
            cmake_path(GET FILE FILENAME FILENAME)
            foreach(NAME ${ARG_NAMES})
                if(${NAME} STREQUAL ${FILENAME})
                    cmake_path(GET FILE PARENT_PATH RESULT_PATH)
                    break()
                endif()
            endforeach()
        endforeach()
    endforeach()

    if(ARG_REQUIRED AND NOT RESULT_PATH)
        message(FATAL_ERROR "The required path(s) \"${ARG_PATHS}\" not found.")
    endif()

    if(RESULT_PATH)
        set(${VAR} ${RESULT_PATH} PARENT_SCOPE)
    endif()
endfunction()
