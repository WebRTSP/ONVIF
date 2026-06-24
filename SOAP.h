#pragma once

#include "stdsoap2.h"

struct SOAP {
    SOAP(soap_mode mode = SOAP_IO_DEFAULT) noexcept {
        soap_init1(&_soap, mode);
    }
    SOAP& operator = (SOAP&) = delete;
    ~SOAP() noexcept {
        soap_destroy(&_soap);
        soap_end(&_soap);
        soap_done(&_soap);
    }

    struct soap* operator -> () noexcept {
        return &_soap;
    }
    operator struct soap* () noexcept {
        return &_soap;
    }

    struct soap _soap;
};
