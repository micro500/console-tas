#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a pre- and a post- target defined where you can add customization code.
#
# This makefile implements macros and targets common to all configurations.
#
# NOCDDL


# Building and Cleaning subprojects are done by default, but can be controlled with the SUB
# macro. If SUB=no, subprojects will not be built or cleaned. The following macro
# statements set BUILD_SUB-CONF and CLEAN_SUB-CONF to .build-reqprojects-conf
# and .clean-reqprojects-conf unless SUB has the value 'no'
SUB_no=NO
SUBPROJECTS=${SUB_${SUB}}
BUILD_SUBPROJECTS_=.build-subprojects
BUILD_SUBPROJECTS_NO=
BUILD_SUBPROJECTS=${BUILD_SUBPROJECTS_${SUBPROJECTS}}
CLEAN_SUBPROJECTS_=.clean-subprojects
CLEAN_SUBPROJECTS_NO=
CLEAN_SUBPROJECTS=${CLEAN_SUBPROJECTS_${SUBPROJECTS}}


# Project Name
PROJECTNAME=nes-snes-replay.X

# Active Configuration
DEFAULTCONF=USB_Standalone
CONF=${DEFAULTCONF}

# All Configurations
ALLCONFS=USB_Standalone USB_Bootloaded_HID NoUSB_Standalone NoUSB_Bootloaded_Serial NoUSB_Bootloaded_HID 


# build
.build-impl: .build-pre
	${MAKE} -f nbproject/Makefile-${CONF}.mk SUBPROJECTS=${SUBPROJECTS} .build-conf


# clean
.clean-impl: .clean-pre
	${MAKE} -f nbproject/Makefile-${CONF}.mk SUBPROJECTS=${SUBPROJECTS} .clean-conf

# clobber
.clobber-impl: .clobber-pre .depcheck-impl
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=USB_Standalone clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=USB_Bootloaded_HID clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=NoUSB_Standalone clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=NoUSB_Bootloaded_Serial clean
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=NoUSB_Bootloaded_HID clean



# all
.all-impl: .all-pre .depcheck-impl
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=USB_Standalone build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=USB_Bootloaded_HID build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=NoUSB_Standalone build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=NoUSB_Bootloaded_Serial build
	    ${MAKE} SUBPROJECTS=${SUBPROJECTS} CONF=NoUSB_Bootloaded_HID build



# dependency checking support
.depcheck-impl:
#	@echo "# This code depends on make tool being used" >.dep.inc
#	@if [ -n "${MAKE_VERSION}" ]; then \
#	    echo "DEPFILES=\$$(wildcard \$$(addsuffix .d, \$${OBJECTFILES}))" >>.dep.inc; \
#	    echo "ifneq (\$${DEPFILES},)" >>.dep.inc; \
#	    echo "include \$${DEPFILES}" >>.dep.inc; \
#	    echo "endif" >>.dep.inc; \
#	else \
#	    echo ".KEEP_STATE:" >>.dep.inc; \
#	    echo ".KEEP_STATE_FILE:.make.state.\$${CONF}" >>.dep.inc; \
#	fi
