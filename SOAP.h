#pragma once

#include "stdsoap2.h"

struct SOAP {
    SOAP(soap_mode mode = SOAP_IO_DEFAULT) noexcept {
        soap_init1(&_soap, mode);
        setLimits();
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

private:
    enum {
        SOAP_TIMEOUT = 3, // seconds
        RECV_MAX_LENGTH = 1024 * 1024, // 1 megabyte
    };

    void setLimits() noexcept {
        _soap.connect_timeout = SOAP_TIMEOUT;
        _soap.send_timeout = SOAP_TIMEOUT;
        _soap.recv_timeout = SOAP_TIMEOUT;
        _soap.transfer_timeout = SOAP_TIMEOUT;
        _soap.recv_maxlength = RECV_MAX_LENGTH;
    }

private:
    struct soap _soap;
};
