cmake_minimum_required(VERSION 3.0)

project(ONVIF)

find_package(OpenSSL REQUIRED)
find_package(PkgConfig REQUIRED)

pkg_search_module(GSOAP REQUIRED gsoap++)
pkg_search_module(GSOAP_SSL REQUIRED gsoapssl++)

find_path(GSOAP_CUSTOM_DIR
    NAMES struct_timeval.h
    HINTS /usr/share/gsoap/custom
)

find_path(GSOAP_PLUGIN_DIR
    NAMES wsseapi.c
    HINTS /usr/share/gsoap/plugin
)

file(GLOB SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    README.md
    generate.sh
    CMakeLists.txt)

set(GSOAP_CUSTOM_SOURCES
    ${GSOAP_CUSTOM_DIR}/struct_timeval.h
    ${GSOAP_CUSTOM_DIR}/struct_timeval.c)

set(GSOAP_PLUGINS_SOURCES
    ${GSOAP_PLUGIN_DIR}/wsaapi.h
    ${GSOAP_PLUGIN_DIR}/wsaapi.c
    ${GSOAP_PLUGIN_DIR}/wsseapi.h
    ${GSOAP_PLUGIN_DIR}/wsseapi.c
    ${GSOAP_PLUGIN_DIR}/smdevp.c
    ${GSOAP_PLUGIN_DIR}/mecevp.c)

foreach(SOURCE_FILE IN LISTS GSOAP_CUSTOM_SOURCES GSOAP_PLUGINS_SOURCES)
    get_filename_component(FILE_EXT ${SOURCE_FILE} EXT)
    if(FILE_EXT STREQUAL ".c")
        set_source_files_properties(${SOURCE_FILE} PROPERTIES LANGUAGE CXX)
    endif()
endforeach()

set(GENERATED
    DeviceBinding.nsmap
    MediaBinding.nsmap
    PullPointSubscriptionBinding.nsmap
    soapC.cpp
    soapDeviceBindingProxy.cpp
    soapDeviceBindingProxy.h
    soapH.h
    soapMediaBindingProxy.cpp
    soapMediaBindingProxy.h
    soapPullPointSubscriptionBindingProxy.cpp
    soapPullPointSubscriptionBindingProxy.h
    soapStub.h
    onvif.h)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/DeviceBinding.nsmap
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/MediaBinding.nsmap
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/PullPointSubscriptionBinding.nsmap
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapC.cpp
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapDeviceBindingProxy.cpp
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapDeviceBindingProxy.h
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapH.h
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapMediaBindingProxy.cpp
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapMediaBindingProxy.h
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapPullPointSubscriptionBindingProxy.cpp
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapPullPointSubscriptionBindingProxy.h
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/soapStub.h
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/onvif.h
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/generate.sh
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

add_library(${PROJECT_NAME}
    ${SOURCES}
    ${GSOAP_CUSTOM_SOURCES}
    ${GSOAP_PLUGINS_SOURCES}
    ${GENERATED})
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
target_compile_definitions(${PROJECT_NAME} PUBLIC
    WITH_OPENSSL
    WITH_DOM)
target_include_directories(${PROJECT_NAME}
    PUBLIC
    ${GSOAP_INCLUDE_DIRS}
    ${GSOAP_PLUGIN_DIR}/../../
    ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(${PROJECT_NAME}
    ${GSOAP_LDFLAGS}
    ${GSOAP_SSL_LDFLAGS}
    ${OPENSSL_LIBRARIES})
