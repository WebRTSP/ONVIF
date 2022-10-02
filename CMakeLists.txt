cmake_minimum_required(VERSION 3.0)

project(ONVIF)

find_package(PkgConfig REQUIRED)

pkg_search_module(GSOAP REQUIRED gsoap++)

file(GLOB_RECURSE WWW_ONVIF_ORG RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    www.onvif.org/*)

file(GLOB SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    README.md
    generate.sh
    CMakeLists.txt)

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
    DEPENDS www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl
    DEPENDS www.onvif.org/ver10/media/wsdl/media.wsdl
    DEPENDS www.onvif.org/ver10/events/wsdl/event.wsdl
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
    ${WWW_ONVIF_ORG}
    ${SOURCES}
    ${GENERATED})
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
target_include_directories(${PROJECT_NAME} PUBLIC
    ${GSOAP_INCLUDE_DIRS}
    ${GSOAP_SHARE_DIR})
target_link_libraries(${PROJECT_NAME}
    ${GSOAP_LDFLAGS})
