#pragma once

#include "stdsoap2.h"

struct SOAP
{
    SOAP() {
        soap_init(&_soap);
    }
    SOAP(soap_mode mode) {
        soap_init1(&_soap, mode);
    }

    SOAP& operator = (SOAP&) = delete;

    ~SOAP() {
        soap_destroy(&_soap);
        soap_end(&_soap);
        soap_done(&_soap);
    }

    struct soap* operator -> () {
        return &_soap;
    }
    operator struct soap* () {
        return &_soap;
    }

    struct soap _soap;
};
