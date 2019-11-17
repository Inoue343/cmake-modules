include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
include(${CMAKE_ROOT}/Modules/CMakeFindDependencyMacro.cmake)

find_dependency(Threads)

macro(find_ffmpeg component)
    set(libname "lib${component}")
    set(headername "${component}.h")

    find_path("${libname}_INCLUDE_PATH"
        NAMES "${libname}/${headername}"
        PATHS "${FFMPEG_DIR}/include"
            "~/Library/Frameworks"
            "/Library/Frameworks"
            "/usr/local/include"
            "/usr/include")

    mark_as_advanced("${${libname}_INCLUDE_PATH}")

    find_library("${libname}_LIBRARY_PATH"
        NAMES "${component}"
        PATHS "${FFMPEG_DIR}/lib"
            "${FFMPEG_DIR}/bin"
            "~/Library/Frameworks"
            "/Library/Frameworks"
            "/usr/local/lib"
            "/usr/local/lib64"
            "/usr/lib"
            "/usr/lib64")

    mark_as_advanced("${${libname}_LIBRARY_PATH}")

    if(${libname}_INCLUDE_PATH AND ${libname}_LIBRARY_PATH)
        file(STRINGS "${${libname}_INCLUDE_PATH}/${libname}/version.h" version_lines
            REGEX "#define LIB.+_VERSION_(MAJOR|MINOR|MICRO)[ \t]+[0-9]+")

        foreach(line ${version_lines})
            if(line MATCHES "MAJOR[ \t]+([0-9]+)")
                set(${libname}_MAJOR_VERSION ${CMAKE_MATCH_1})
            elseif(line MATCHES "MINOR[ \t]+([0-9]+)")
                set(${libname}_MINOR_VERSION ${CMAKE_MATCH_1})
            elseif(line MATCHES "MICRO[ \t]+([0-9]+)")
                set(${libname}_MICRO_VERSION ${CMAKE_MATCH_1})
            endif()
        endforeach()

        set(FFMPEG_${libname}_FOUND TRUE)
        get_filename_component(${libname}_LIBRARY_DIR "${${libname}_LIBRARY_PATH}" DIRECTORY)
    endif()
endmacro()

find_ffmpeg(avcodec)
find_ffmpeg(avdevice)
find_ffmpeg(avfilter)
find_ffmpeg(avformat)
find_ffmpeg(avutil)
find_ffmpeg(swresample)
find_ffmpeg(swscale)

set(version_file "${libavutil_INCLUDE_PATH}/libavutil/ffversion.h")
if(EXISTS ${version_file})
	file(STRINGS ${version_file} ffmpeg_version
        REGEX "#define FFMPEG_VERSION \".+\"")

    foreach(line ${ffmpeg_version})
        if(line MATCHES "#define FFMPEG_VERSION \"(.+)\"")
            set(FFMPEG_VERSION ${CMAKE_MATCH_1})
        endif()
    endforeach()
endif()

if(FFMPEG_libavcodec_FOUND OR FFMPEG_libavdevice_FOUND OR FFMPEG_libavfilter_FOUND OR FFMPEG_libavformat_FOUND OR FFMPEG_libavutil_FOUND OR FFMPEG_libswresample_FOUND OR FFMPEG_libswscale_FOUND)
    list(APPEND FFMPEG_INCLUDE_DIRS
        ${libavcodec_INCLUDE_PATH}
        ${libavdevice_INCLUDE_PATH}
        ${libavfilter_INCLUDE_PATH}
        ${libavformat_INCLUDE_PATH}
        ${libavutil_INCLUDE_PATH}
        ${libswresample_INCLUDE_PATH}
        ${libswscale_INCLUDE_PATH})

    list(APPEND FFMPEG_LIBRARY_DIRS
        ${libavcodec_LIBRARY_DIR}
        ${libavdevice_LIBRARY_DIR}
        ${libavfilter_LIBRARY_DIR}
        ${libavformat_LIBRARY_DIR}
        ${libavutil_LIBRARY_DIR}
        ${libswresample_LIBRARY_DIR}
        ${libswscale_LIBRARY_DIR})

    list(APPEND FFMPEG_LIBRARIES
        ${libavcodec_LIBRARY_PATH}
        ${libavdevice_LIBRARY_PATH}
        ${libavfilter_LIBRARY_PATH}
        ${libavformat_LIBRARY_PATH}
        ${libavutil_LIBRARY_PATH}
        ${libswresample_LIBRARY_PATH}
        ${libswscale_LIBRARY_PATH})

    list(REMOVE_DUPLICATES FFMPEG_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES FFMPEG_LIBRARY_DIRS)
    list(REMOVE_DUPLICATES FFMPEG_LIBRARIES)

    set(FFMPEG_INCLUDE_DIRS ${FFMPEG_INCLUDE_DIRS} CACHE STRING "")
    set(FFMPEG_LIBRARY_DIRS ${FFMPEG_LIBRARY_DIRS} CACHE STRING "")
    set(FFMPEG_LIBRARIES ${FFMPEG_LIBRARIES} CACHE STRING "")
    set(FFMPEG_FOUND TRUE)

#    message(STATUS "Found ffmpeg: (found version \"${FFMPEG_VERSION}\")")

#   if(FFMPEG_libavcodec_FOUND)
#        message(STATUS "Found libavcodec: ${libavcodec_LIBRARY_PATH} (found version \"${libavcodec_MAJOR_VERSION}.${libavcodec_MINOR_VERSION}.${libavcodec_MICRO_VERSION}\")")
#    else()
#        message(STATUS "Not found libavcodec")
#    endif()

#    if(FFMPEG_libavdevice_FOUND)
#        message(STATUS "Found libavdevice: ${libavdevice_LIBRARY_PATH} (found version \"${libavdevice_MAJOR_VERSION}.${libavdevice_MINOR_VERSION}.${libavdevice_MICRO_VERSION}\")")
#    else()
#        message(STATUS "Not found libavdevice")
#    endif()

#    if(FFMPEG_libavfilter_FOUND)
#        message(STATUS "Found libavdevice: ${libavdevice_LIBRARY_PATH} (found version \"${libavfilter_MAJOR_VERSION}.${libavfilter_MINOR_VERSION}.${libavfilter_MICRO_VERSION}\")")
#    else()
#        message(STATUS "Not found libavibavfiltercodec")
#    endif()

#    if(FFMPEG_libavformat_FOUND)
#        message(STATUS "Found libavformat: ${libavformat_LIBRARY_PATH} (found version \"${libavformat_MAJOR_VERSION}.${libavformat_MINOR_VERSION}.${libavformat_MICRO_VERSION}\")")
#    else()
#        message(STATUS "Not found libavformat")
#    endif()

#    if(FFMPEG_libavutil_FOUND)
#        message(STATUS "Found libavutil: ${libavutil_LIBRARY_PATH} (found version \"${libavutil_MAJOR_VERSION}.${libavutil_MINOR_VERSION}.${libavutil_MICRO_VERSION}\")")
#    else()
#        message(STATUS "Not found libavutil")
#    endif()

#    if(FFMPEG_libswresample_FOUND)
#        message(STATUS "Found libswresample: ${libswresample_LIBRARY_PATH} (found version \"${libswresample_MAJOR_VERSION}.${libswresample_MINOR_VERSION}.${libswresample_MICRO_VERSION}\")")
#    else()
#        message(STATUS "Not found libswresample")
#    endif()

#    if(FFMPEG_libswscale_FOUND)
#        message(STATUS "Found libswscale: ${libswscale_LIBRARY_PATH} (found version \"${libswscale_MAJOR_VERSION}.${libswscale_MINOR_VERSION}.${libswscale_MICRO_VERSION}\")")
#    else()
#        message(STATUS "Not found libswscal")
#    endif()
endif()

find_package_handle_standard_args(FFMPEG
    REQUIRED_VARS FFMPEG_INCLUDE_DIRS FFMPEG_LIBRARIES FFMPEG_LIBRARY_DIRS
    VERSION_VAR FFMPEG_VERSION)
