#!/bin/bash -e

if [[ -z "${http_proxy}" ]]; then
    PROXY=""
else
    PROXY=${http_proxy#"http://"}
    PROXY=-r${PROXY%"/"}
fi

if [[ -z "$1" ]]; then
    OUT_FILE=./onvif.h
    OUT_DIR=
else
    OUT_FILE="$1/onvif.h"
    OUT_DIR="-d $1"
fi

if [[ -z "${GSOAP_ROOT}" ]]; then
    GSOAP_I=""
    WSDL2H="wsdl2h"
    SOAPCPP2="soapcpp2"
else
    GSOAP_I="-I${GSOAP_ROOT}/share/gsoap:${GSOAP_ROOT}/share/gsoap/import:${GSOAP_ROOT}/share/gsoap/custom"
    WSDL2H="${GSOAP_ROOT}/bin/wsdl2h"
    SOAPCPP2="${GSOAP_ROOT}/bin/soapcpp2"
fi

# -c++11  generate C++11 source code
# -d      use DOM to populate xs:any, xs:anyType, and xs:anyAttribute
# -p      create polymorphic types inherited from base xsd__anyType
# -O4     optimize -O3 and omit unused schema root elements (use only with WSDLs)
# -ofile  output to file
(set -x; ${WSDL2H} -c++11 -d -p -O4 -o ${OUT_FILE} \
    ${PROXY} \
    https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl \
    https://www.onvif.org/ver10/media/wsdl/media.wsdl \
    https://www.onvif.org/ver10/events/wsdl/event.wsdl)

# from https://www.genivia.com/doc/wsse/html/wsse.html:
# `#import "wsse.h"`
# The wsdl2h tool adds the necessary import directives to the generated header file
# if the WSDL declares the use of WS-Security.
# If not, you may have to add the import directive shown above manually before running soapcpp2.
cat >> ${OUT_FILE} << EOL

#import "wsse.h"
#import "wsdd5.h"
EOL

# -c++11 Generate C++ source code optimized for C++11 (compile with -std=c++11).
# -2     Generate SOAP 1.2 source code.
# -C     Generate client-side source code only.
# -x     Do not generate sample XML message files.
# -t     Generate source code for fully xsi:type typed SOAP/XML messages.
# -a     Use HTTP SOAPAction with WS-Addressing to invoke server-side operations.
# -L     Do not generate soapClientLib/soapServerLib.
# FIXME? recommended command from WS-Discovery plugin docs: soapcpp2 -a -L -pwsdd -Iimport import/wsdd.h
(set -x; ${SOAPCPP2} -c++11 -2 -C -x -t -a -L ${GSOAP_I} ${OUT_FILE} ${OUT_DIR})
