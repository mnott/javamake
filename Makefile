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
#################################################


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
	echo "=========================================="
	echo "Welcome to this massively informative help"
	echo "=========================================="
	echo 
	echo "You have the following targets:           "
	echo 
	echo "make            Make the project          "
	echo
	echo "make clean      Clean the project         "
	echo
	echo "make compile    Compile the project       "
	echo
	echo "make deploy     Deploy the project        "
	echo

	echo
	echo "=========================================="



.PHONY: test
test :
	echo $$PATH



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
	for src in $$SOURCES; do \
		cd $$src; \
		rsync -avzh --delete --include='*/' --exclude='*' . ../$$WEBROOT/WEB-INF/classes/; \
		find . -name *class -exec sh -c 'mv $$(dirname $$1)/$$(basename $$1) ../$$WEBROOT/WEB-INF/classes/$$(dirname $$1)' _ "{}"  \; ;\
		find . -name *java  -exec sh -c 'f=$$(basename $$1);fn=$$(dirname $$1)/$${f%.*};if test $${fn}.java -nt ../$$WEBROOT/WEB-INF/classes/$${fn}.class ; then echo $${fn}.java ; javac -d . -cp $${CLASSPATH}:. $${fn}.java && mv $${fn}.class ../$$WEBROOT/WEB-INF/classes/$${fn}.class; fi' _ "{}"  \; ;\
		find . -name *class -exec sh -c 'mv $$(dirname $$1)/$$(basename $$1) ../$$WEBROOT/WEB-INF/classes/$$(dirname $$1)' _ "{}"  \; ;\
	done;



#################################################
# 
# Deploy
#
#################################################

.PHONY: deploy
deploy : check compile
	$(MAKE) log msg="make deploy" LVL=info
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
# Remove all temporary tex-files
#
#################################################

.PHONY: clean
clean :
	$(MAKE) log lvl=info msg="make clean"
	
	if [ -d "$$TOMCAT/webapps/$$WEBAPP" ]; then \
		rm -rf "$$TOMCAT/webapps/$$WEBAPP"; \
	fi; \

	if [ -d $$WEBROOT/WEB-INF/classes ]; then \
		rm -rf $$WEBROOT/WEB-INF/classes; \
		mkdir $$WEBROOT/WEB-INF/classes; \
	fi;



#################################################
# 
# Rudimentary logging functionality
#
#################################################

.PHONY: log
log :
	if [ "$$silent" == "1" ] ; then exit 0; fi
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
