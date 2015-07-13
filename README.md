Welcome to javamake!
=====================


Summary
---------

This small Makefile was born out of the urge to quickly build an Eclipse project when Eclipse stopped working due to Apple's infinite wisdom breaking visual Java applications during  one of their upgrade packages.

The file is self-descriptive: I assume you have a java Eclipse project, and make etc. installed.


----------

Installation
---------

Copy **Makefile** into your java project folder and go to that folder on the command line. Modify **Makefile** according to your needs. The configuration section is at the top of the file. You'll have to define the java libraries that you need for compiling (**classpath**) and those that you want to deploy. Also you'll have to have a working installation of Tomcat somewhere into which you want to copy the assembled project.

Right now, the compilation phase compiles all changed java files inside the source folder(s) into WebRoot/WEB-INF/classes, add the required runtime libraries, and then copy over everything to the webapps folder of Tomcat. We also touch web.xml in order to force e restart of the web app.


----------

Usage
---------

Just call

```
# make
```

To see the help screen. To compile, you do

```
# make compile
```

To deploy (and implicitly compile), you do

```
# make deploy
```

To clean your target web app as well as your classes folder, you do

```
# make clean
```

This may make sense e.g. when you remove files from the deployment.
