#################################################
# 
# Makefile for Java
#
# (c) 2015 Matthias Nott
#
#################################################


#################################################
# 
# Configuration
# 
# All configurations may depend on the local
# development environment. For this reason,
# we only list the configuration variables
# here and give some values; the actual
# configuration file may overwrite them.
#
#################################################

#
# Makefile that is not commited to git and that
# will overwrite configuration variables done
# in this file.
# 
MAKE_CONFIG=make.properties

#
# Our javac lives in $$JAVA_HOME/bin
# 
JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk/Contents/Home

#
# Tomcat target deployment directory. This directory
# contains the webapps directory, into which we are
# going to deploy our web application.
#
TOMCAT=/pgm/java/tomcat/apache-tomcat-8.0.23/

#
# Name of the webapp we are going to deploy into.
# This is a directory we are going to create under
# $$TOMCAT/webapps.
#
WEBAPP=ui5bp

#
# Webroot folder inside your Eclipse directory.
#
WEBROOT=WebRoot

#
# Source Folders relative to the project root of
# the project. More than one need to be space
# separated
#
SOURCES=src

#
# Content that is to be deployed to WEB-INF/classes,
# relative to the project root of the project. More
# than one location to be separated by spaces.
#
TO_CLASSES=config/dev/* data/*

#
# Content that is to be copied to WEB-INF/lib,
# relative to the project root of the project. More
# than one location to be separated by spaces.
#
TO_LIB=lib/gson-2.3.1.jar lib/log4j.jar lib/mysql-connector-java-5.1.7-bin.jar lib/ngdbc.jar lib/sap/*jar


#
# Classpath. This is what we need to complie the web application's
# class files. It is not necessarily identical with what we need
# to deploy into WEB-INF/lib: It is what we need to compile.
# 
CLASSPATH=../$$WEBROOT/WEB-INF/classes:../lib/gson-2.3.1.jar:../lib/log4j.jar:lib/mysql-connector-java-5.1.7-bin.jar:../lib/ngdbc.jar:../lib/servlet-api.jar


#################################################
# 
# HCP Specific configuration
# 
# HCP Prooperties can be set in a proerties file,
# which is not going to be part of the git commit
# as it may contain passwords, or it can be set
# directly in this file. We're showing below the
# parameters that are otherwise set in the
# properties file; since we do set a properties
# file, the values specified in this Makefile
# are not going to be used, but those of the
# properties file (if it exists).
#
#################################################

#
# Configuration file for HCP parameters. If it
# exists, it can overwrite the parameters set
# in this Makefile.
# 
HCP_CONFIG=config/hcp/hcp.properties

#
# HCP Hostname
#
HCP_HOST=hanatrial.ondemand.com

#
# HCP Account Name
#
HCP_ACCOUNT=i052341trial

#
# HCP Username
# 
HCP_USER=i052341

#
# HCP User Password
# 
HCP_PASS=topsecret

#
# Location of the neo.sh script
#
HCP_SDK=/pgm/java/hanacloudsdk/tools

#
# HCP Runtime Version
#
HCP_RUNTIME_VERSION=2

#
# HCP JAVA VERSION
#
HCP_JAVA_VERSION=8


#################################################
# 
# End of Configuration
#
#################################################

PATH:=$(JAVA_HOME)/bin:$(PATH)

ifdef loglvl
  LOGLVL=$(loglvl)
endif

ifdef LOGLEVEL
  LOGLVL=$(loglvl)
endif

ifdef loglevel
  LOGLVL=$(loglevel)
endif

ifndef LOGLVL
  LOGLVL=INFO
endif

ifdef lvl
	LVL=$(lvl)
endif

ifndef LVL
	LVL=DEBUG
endif

ifndef DEST
	DEST=tmp
endif


ifeq ($(MAKE),)
    MAKE := make
endif

define uc
$(shell echo $1 | tr a-z A-Z)
endef

PACKAGE    = document
VERSION    = 0.1

.SILENT :

.EXPORT_ALL_VARIABLES :

.NOTPARALLEL :


#################################################
#
# Help function
#
#################################################
.PHONY: help
help :

	echo
	echo "============================================="
	echo "Welcome to this massively informative help..."
	echo "============================================="
	echo 
	echo "You have the following targets:              "
	echo 
	echo "make              Make the project           "
	echo
	echo "make clean        Clean the project          "
	echo
	echo "make compile      Compile the project        "
	echo
	echo "make deploy       Deploy the project         "
	echo
	echo "make hcpdeploy    Deploy the project to HCP  "
	echo
	echo "make hcpundeploy  Deploy the project to HCP  "
	echo
	echo "make hcpstop      Stop the HCP webapp        "
	echo
	echo "make hcpstart     Start the HCP webapp       "
	echo
	echo "make hcprestart   Restart the HCP webapp     "
	echo
	echo "make hcpstatus    Get the HCP webapp status  "
	echo
	echo "make hcpruntimes  List available HCP runtimes"
	echo

	echo
	echo "============================================="



.PHONY: test
test :
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -f "$$HCP_CONFIG" ]; then \
		for i in $$(cat "$$HCP_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	echo JAVA_HOME=$$JAVA_HOME;\
	echo TOMCAT=$$TOMCAT;



#################################################
#
# Initial Things we mostly always want to do.
#
#################################################

.PHONY: check
check :
	$(MAKE) log msg="make check" LVL=debug
	#
	# Check for maximum level of recursion
	#
	if [ $(MAKELEVEL) -gt 20 ]; then \
		$(MAKE) log lvl=fatal msg="Maximum recursion level reached. Aborting."; \
		exit 1; \
	else \
	  $(MAKE) log lvl=debug msg="Recursion level: $(MAKELEVEL)"; \
	fi;




#################################################
# 
# Run
#
#################################################

.PHONY: run
run : check compile
	$(MAKE) log msg="make compile" LVL=info


#################################################
# 
# Compile
#
#################################################

.PHONY: compile
compile : check
	$(MAKE) log msg="make compile" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	for src in $$SOURCES; do \
		cd $$src; \
		java -version;\
		rsync -avzh --delete --include='*/' --exclude='*' . ../$$WEBROOT/WEB-INF/classes/; \
		find . -name *class -exec sh -c 'mv $$(dirname $$1)/$$(basename $$1) ../$$WEBROOT/WEB-INF/classes/$$(dirname $$1)' _ "{}"  \; ;\
		find . -name *java  -exec sh -c 'f=$$(basename $$1);fn=$$(dirname $$1)/$${f%.*};if test ! -f ../$$WEBROOT/WEB-INF/classes/$${fn}.class -o $${fn}.java -nt ../$$WEBROOT/WEB-INF/classes/$${fn}.class; then echo $${fn}.java ; javac -d . -cp $${CLASSPATH}:. $${fn}.java && mv $${fn}.class ../$$WEBROOT/WEB-INF/classes/$${fn}.class; fi' _ "{}"  \; ;\
		find . -name *class -exec sh -c 'mv $$(dirname $$1)/$$(basename $$1) ../$$WEBROOT/WEB-INF/classes/$$(dirname $$1)' _ "{}"  \; ;\
	done;


#################################################
#
# HCP List Runtime Versions 
#
#################################################

.PHONY: hcpruntimes
hcpruntimes : check
	$(MAKE) log msg="make hcpruntimeversions" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -f "$$HCP_CONFIG" ]; then \
		for i in $$(cat "$$HCP_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	$$HCP_SDK/neo.sh list-runtime-versions -h $$HCP_HOST -u $$HCP_USER -p $$HCP_PASS; \
	$$HCP_SDK/neo.sh list-runtimes -h $$HCP_HOST -u $$HCP_USER -p $$HCP_PASS;


#################################################
# 
# Deploy
#
#################################################

.PHONY: deploy
deploy : check compile
	$(MAKE) log msg="make deploy" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ ! -d "$$TOMCAT/webapps/$$WEBAPP" ]; then \
		mkdir "$$TOMCAT/webapps/$$WEBAPP"; \
	fi; \
	cd $$WEBROOT; \
	touch WEB-INF/web.xml; \
	for i in $$TO_CLASSES; do rsync -avzh ../$$i WEB-INF/classes/; done; \
	for i in $$TO_LIB; do rsync -avzh ../$$i WEB-INF/lib/; done; \
	rsync -avzh --delete . "$$TOMCAT/webapps/$$WEBAPP/" ;


#################################################
# 
# Undeploy
#
#################################################

.PHONY: undeploy
undeploy : check
	$(MAKE) log msg="make undeploy" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -d "$$TOMCAT/webapps/$$WEBAPP" ]; then \
		rm -rf "$$TOMCAT/webapps/$$WEBAPP"; \
	fi;



#################################################
# 
# HCP Deploy
#
#################################################

.PHONY: hcpdeploy
hcpdeploy : check compile
	$(MAKE) log msg="make hcpdeploy" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -f "$$HCP_CONFIG" ]; then \
		for i in $$(cat "$$HCP_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ ! -d tmp ]; then \
		mkdir tmp; \
	fi; \
	cd $$WEBROOT; \
	touch WEB-INF/web.xml; \
	for i in $$TO_CLASSES; do rsync -avzh ../$$i WEB-INF/classes/; done; \
	for i in $$TO_LIB; do rsync -avzh ../$$i WEB-INF/lib/; done; \
	zip -u -r ../tmp/$$WEBAPP.war *; \
	$$HCP_SDK/neo.sh deploy -h $$HCP_HOST -u $$HCP_USER --application $$WEBAPP --source ../tmp/$$WEBAPP.war --runtime-version $$HCP_RUNTIME_VERSION -j $$HCP_JAVA_VERSION --delta -a $$HCP_ACCOUNT -p $$HCP_PASS;



#################################################
# 
# HCP Undeploy
#
#################################################

.PHONY: hcpundeploy
hcpundeploy : check hcpstop
	$(MAKE) log msg="make hcpundeploy" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -f "$$HCP_CONFIG" ]; then \
		for i in $$(cat "$$HCP_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	$$HCP_SDK/neo.sh undeploy -h $$HCP_HOST -u $$HCP_USER --application $$WEBAPP -a $$HCP_ACCOUNT -p $$HCP_PASS;


#################################################
# 
# HCP Stop
#
#################################################

.PHONY: hcpstop
hcpstop : check
	$(MAKE) log msg="make hcpstop" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -f "$$HCP_CONFIG" ]; then \
		for i in $$(cat "$$HCP_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	$$HCP_SDK/neo.sh stop -h $$HCP_HOST -u $$HCP_USER --application $$WEBAPP -a $$HCP_ACCOUNT -p $$HCP_PASS;


#################################################
# 
# HCP Start
#
#################################################

.PHONY: hcpstart
hcpstart : check
	$(MAKE) log msg="make hcpstart" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -f "$$HCP_CONFIG" ]; then \
		for i in $$(cat "$$HCP_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	$$HCP_SDK/neo.sh start -h $$HCP_HOST -u $$HCP_USER --application $$WEBAPP -a $$HCP_ACCOUNT -p $$HCP_PASS;


#################################################
# 
# HCP Restart
#
#################################################

.PHONY: hcprestart
hcprestart : check
	$(MAKE) log msg="make hcprestart" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -f "$$HCP_CONFIG" ]; then \
		for i in $$(cat "$$HCP_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	$$HCP_SDK/neo.sh restart -h $$HCP_HOST -u $$HCP_USER --application $$WEBAPP -a $$HCP_ACCOUNT -p $$HCP_PASS;


#################################################
# 
# HCP Status
#
#################################################

.PHONY: hcpstatus
hcpstatus : check
	$(MAKE) log msg="make hcpstatus" LVL=info
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -f "$$HCP_CONFIG" ]; then \
		for i in $$(cat "$$HCP_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	$$HCP_SDK/neo.sh status -h $$HCP_HOST -u $$HCP_USER --application $$WEBAPP -a $$HCP_ACCOUNT -p $$HCP_PASS;




#################################################
# 
# Remove all generated files
#
#################################################

.PHONY: clean
clean : check
	$(MAKE) log lvl=info msg="make clean"
	
	if [ -f "$$MAKE_CONFIG" ]; then \
		for i in $$(cat "$$MAKE_CONFIG" | sed '/^\#/d' | sed '/^$$/d' | sed -e 's/ //g') ; do a=`echo $$i|cut -d"=" -f 1`; b=`echo $$i|cut -d"=" -f 2`; export $$a=$$b; done; \
	fi; \
	if [ -d "$$TOMCAT/webapps/$$WEBAPP" ]; then \
		rm -rf "$$TOMCAT/webapps/$$WEBAPP"; \
	fi; \
	if [ -d $$WEBROOT/WEB-INF/classes ]; then \
		rm -rf $$WEBROOT/WEB-INF/classes; \
		mkdir $$WEBROOT/WEB-INF/classes; \
	fi; \
	if [ -f tmp/$$WEBAPP.war ]; then \
		rm -f tmp/$$WEBAPP.war; \
	fi;



#################################################
# 
# Rudimentary logging functionality
#
#################################################

.PHONY: log
log :
	if [ "$$silent" = "1" ] ; then exit 0; fi
	#
	# Log levels are DEBUG, INFO, WARN, ERROR, FATAL 
	#
	case "$(call uc,$(LVL))" in\
		DEBUG|"")\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG)\
					echo $$msg;\
			esac;\
			;;\
		INFO)\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG|INFO)\
					echo $$msg;\
			esac;\
			;;\
		WARN)\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG|INFO|WARN)\
					echo $$msg;\
			esac;\
			;;\
		ERROR)\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG|INFO|WARN|ERROR)\
					echo $$msg;\
			esac;\
			;;\
		FATAL)\
			case "$(call uc,$(LOGLVL))" in\
				DEBUG|INFO|WARN|ERROR|FATAL)\
					echo $$msg;\
			esac;\
			;;\
  esac;\
