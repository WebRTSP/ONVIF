#!/bin/bash -e

if [[ -z "${http_proxy}" ]]; then
    PROXY=""
else
    PROXY=${http_proxy#"http://"}
    PROXY=-r${PROXY%"/"}
fi


# -c++11  generate C++11 source code
# -d      use DOM to populate xs:any, xs:anyType, and xs:anyAttribute
# -p      create polymorphic types inherited from base xsd__anyType
# -O4     optimize -O3 and omit unused schema root elements (use only with WSDLs)
# -ofile  output to file
wsdl2h -c++11 -d -p -O4 -o onvif.h \
    ${PROXY} \
    www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl \
    www.onvif.org/ver10/media/wsdl/media.wsdl \
    www.onvif.org/ver10/events/wsdl/event.wsdl

# -c++11 Generate C++ source code optimized for C++11 (compile with -std=c++11).
# -2     Generate SOAP 1.2 source code.
# -C     Generate client-side source code only.
# -j     Generate C++ service proxies and objects that share a soap struct.
# -x     Do not generate sample XML message files.
# -t     Generate source code for fully xsi:type typed SOAP/XML messages.
soapcpp2 -c++11 -2 -C -j -x -t onvif.h
