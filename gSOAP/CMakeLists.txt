cmake_minimum_required(VERSION 3.28)

project(gSOAP)

include(ExternalProject)

ExternalProject_Add(gSOAP
    URL https://downloads.sourceforge.net/project/gsoap2/gsoap_2.8.142.zip
    URL_HASH SHA1=86066ec72c35e335137606bcdc77c9b4d899d0a5
    SOURCE_DIR ${GSOAP_SOURCE_TARGET_DIR}
    INSTALL_DIR "${CMAKE_INSTALL_PREFIX}"
    CONFIGURE_COMMAND "<SOURCE_DIR>/configure" "--prefix=<INSTALL_DIR>"
    BUILD_COMMAND $(MAKE)
    INSTALL_COMMAND $(MAKE) install
    BUILD_ALWAYS YES
)
