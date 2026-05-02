cmake_minimum_required(VERSION 3.10)

project(ONVIF)


set(GSOAP_BIN_FILES
    wsdl2h
    soapcpp2
)

set(GSOAP_FILES
    stdsoap2.h
    stdsoap2.cpp
    dom.cpp
)

set(GSOAP_CUSTOM_FILES
    struct_timeval.h
    struct_timeval.c
)

set(GSOAP_PLUGINS_FILES
    wsaapi.h
    wsaapi.c
    wsseapi.h
    wsseapi.c
    wsddapi.h
    wsddapi.c
    smdevp.c
    mecevp.c
)

if(ANDROID OR LINUX)
    set(GSOAP_ROOT "${CMAKE_CURRENT_BINARY_DIR}/gSOAP")
    set(GSOAP_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/gSOAP.src")

    foreach(GSOAP_BIN_FILE IN LISTS GSOAP_BIN_FILES)
        list(APPEND GSOAP_BINARIES "${GSOAP_ROOT}/bin/${GSOAP_BIN_FILE}")
    endforeach()

    foreach(GSOAP_FILE IN LISTS GSOAP_FILES)
        list(APPEND GSOAP_SOURCES "${GSOAP_SOURCE_DIR}/gsoap/${GSOAP_FILE}")
    endforeach()

    foreach(GSOAP_CUSTOM_FILE IN LISTS GSOAP_CUSTOM_FILES)
        list(APPEND GSOAP_CUSTOM_SOURCES "${GSOAP_ROOT}/share/gsoap/custom/${GSOAP_CUSTOM_FILE}")
    endforeach()

    foreach(GSOAP_PLUGIN_FILE IN LISTS GSOAP_PLUGINS_FILES)
        list(APPEND GSOAP_PLUGINS_SOURCES "${GSOAP_ROOT}/share/gsoap/plugin/${GSOAP_PLUGIN_FILE}")
    endforeach()

    foreach(GSOAP_FILE IN LISTS GSOAP_BINARIES GSOAP_SOURCES GSOAP_CUSTOM_SOURCES GSOAP_PLUGINS_SOURCES)
        if(NOT EXISTS ${GSOAP_FILE})
            set(BUILD_GSOAP TRUE)
        endif()
    endforeach()

    if(BUILD_GSOAP)
        # 1. clean command erases all files marked as GENERATED
        # 2. add_custom_command marks all OUTPUT files as GENERATED
        # 3. add_library expects already existing files or marked as GENERATED
        # so the only way I found to make everybody happy after clean
        # is build gSOAP on cmake configure step with execute_process.
        execute_process(
            COMMAND
                ${CMAKE_COMMAND}
                -S "${CMAKE_CURRENT_SOURCE_DIR}/gSOAP"
                -B "${CMAKE_CURRENT_BINARY_DIR}/gSOAP.build"
                "-DGSOAP_SOURCE_TARGET_DIR=${GSOAP_SOURCE_DIR}"
                "-DCMAKE_INSTALL_PREFIX=${GSOAP_ROOT}"
        )
        execute_process(
            COMMAND
                ${CMAKE_COMMAND} --build
                "${CMAKE_CURRENT_BINARY_DIR}/gSOAP.build"
        )
    endif()
endif()

if(ANDROID)
    include(FetchContent)
    FetchContent_Declare(
        android_openssl
        DOWNLOAD_EXTRACT_TIMESTAMP true
        URL https://github.com/KDAB/android_openssl/archive/refs/heads/master.zip
    )
    FetchContent_MakeAvailable(android_openssl)
    include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)
else()
    find_package(OpenSSL REQUIRED)
endif()

find_package(ZLIB REQUIRED)
find_library(LIBM m REQUIRED)

set(SOURCES
    generate.sh
    SOAP.h
    CMakeLists.txt
)

set(GSOAP_GENERATED_FILES
    DeviceBinding.nsmap
    MediaBinding.nsmap
    PullPointSubscriptionBinding.nsmap
    wsdd.nsmap
    onvif.h
    soapH.h
    soapClient.cpp
    soapStub.h
    soapC.cpp
)

set(GSOAP_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated/ONVIF")

foreach(GENERATED_FILE IN LISTS GSOAP_GENERATED_FILES)
    list(APPEND GSOAP_GENERATED_SOURCES "${GSOAP_GENERATED_DIR}/${GENERATED_FILE}")
endforeach()

add_custom_command(
    DEPENDS ${GSOAP_BINARIES}
    OUTPUT ${GSOAP_GENERATED_SOURCES}
    COMMAND mkdir -p "${GSOAP_GENERATED_DIR}"
    COMMAND
        ${CMAKE_COMMAND} -E env
        GSOAP_ROOT="${GSOAP_ROOT}"
        --
        "${CMAKE_CURRENT_SOURCE_DIR}/generate.sh" "${GSOAP_GENERATED_DIR}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

foreach(SOURCE_FILE IN LISTS GSOAP_CUSTOM_SOURCES GSOAP_PLUGINS_SOURCES)
    get_filename_component(FILE_EXT ${SOURCE_FILE} EXT)
    if(FILE_EXT STREQUAL ".c")
        set_source_files_properties(${SOURCE_FILE} PROPERTIES LANGUAGE CXX)
    endif()
endforeach()

add_library(${PROJECT_NAME}
    ${SOURCES}
    ${GSOAP_SOURCES}
    ${GSOAP_CUSTOM_SOURCES}
    ${GSOAP_PLUGINS_SOURCES}
    ${GSOAP_GENERATED_SOURCES}
)
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
target_compile_definitions(${PROJECT_NAME}
    PUBLIC
        WITH_OPENSSL
        WITH_GZIP
        WITH_DOM
)
target_include_directories(${PROJECT_NAME}
    PUBLIC
        "${GSOAP_SOURCE_DIR}"
        "${GSOAP_SOURCE_DIR}/gsoap"
        "${GSOAP_GENERATED_DIR}"
        "${GSOAP_GENERATED_DIR}/../"
)
target_link_libraries(${PROJECT_NAME}
    PUBLIC
        ZLIB::ZLIB
        ${LIBM}
)

if(ANDROID)
    add_android_openssl_libraries(${PROJECT_NAME})
else()
    target_link_libraries(${PROJECT_NAME}
        PUBLIC
            ${OPENSSL_LIBRARIES}
    )
endif()
