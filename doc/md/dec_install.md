# Install OS Dependencies

DEC SW is compatible with any POSIX OS. The information contained in this section aims to ensure that the ruby interpreter can be built at the target platform ; this approach aims for active obsolescence management allowing to make usage of recent stable versions avoiding lock-down by the OS distribution packages, which are usually very constraining in this respect. The SW packages are the very few which are requiring an OS administrator profile (i.e. root user) whilst DEC SW is recommended to live in the OS user environment which will execute it.

## Debian / Ubuntu based distributions

The packages required for Linux distributions based on Debian package manager are listed below:

In order to generate the documentation in pdf, please install the following package:

## Red-Hat based distributions

The installation of packages with RHEL based distributions are constrained by the repositories configured ; official RHEL lack yum support for some of the above SW packages listed in previous section for Debian / Ubuntu based distributions.

The packages required for Linux distributions based on Red-Hat based distributions are listed below:

The following dependencies can be installed manually using rpm available at Nexus:

     ncftp-3.2.5-18.el8.x86_64.rpm
     p7zip-16.02-20.el7.x86_64.rpm
     sshpass-1.09-4.el8.x86_64.rpm

## macOS

The installation of SW dependencies in macOS can be resolved in different ways ; the tools which are not natively available with the OS or XCode development environment are installed using the package manager \"brew\" ; openssl is however shipped with macOS but its underlying library libressl does not support some of the algorithms used, therefore it is required to install it with brew and ensure its execution prevails over the native version.

# Install Ruby

This section covers the install of *Ruby* interpreter and the *gem* dependencies needed by DEC SW. It is recommended that the *Ruby* interpreter is done locally for the Linux user who shall execute the DEC SW.

The *Ruby* interpreter can be obtained and installed in many different ways ; this manual describes how to install it local to the OS user which shall execute the DEC SW. Different runtime managers are addressed in the following sections to ease the installation and eventual futures updates in a seamless manner.

## asdf

This section addresses how to install ruby based on [asdf](https://asdf-vm.com/guide/getting-started.html#_1-install-dependencies), which is a command-line tool run-time manager for different languages and development stacks, including ruby.

Download the tool:

Add the following entry to \$HOME/.bash_profile

Then install / update the asdf ruby plug-in:

Now it is possible to select the ruby run-time version and easily install it for usage:

    1.8.5-p52
    1.8.5-p113
    1.8.5-p114
    1.8.5-p115
    1.8.5-p231
    1.8.6
    (...)
    3.0.0-dev
    3.0.0-preview1
    3.0.0-preview2
    3.0.0-rc1
    3.0.0
    3.0.1
    3.0.2
    3.0.3
    3.1.0-dev
    3.1.0-preview1
    3.1.0
    3.1.1
    3.1.2
    3.1.3
    3.1.4
    3.1.5
    3.1.6
    3.2.0-dev
    (...)

Install the ruby run times specifying the version of choice, first to be downloaded and then to select it for local execution:

Now it is usually required to restart the shell upon installation to point the new ruby interpreter run-time.

## RVM

This section addresses how to install ruby based on [RVM](https://rvm.io/), which is a command-line tool which allows you to easily install, manage, and work with multiple ruby environments from interpreters to sets of gems.

Alternatively to the latest ruby stable installation, the following command installs a specific version of ruby interpreter ; the version specified below corresponds to the one used for the unit tests and it is required as a mandatory precondition at installation time according to the gem file definition.

Different versions can be locally installed and select the one of choice at any time. However the following ruby version is recommended:

# Install DEC SW

In order to install DEC SW and the gems required, execute the following commands in the shell:

It is usually recommended to perform the installation of every DEC node with a dedicated installer, which already carries the desired configuration according to the defined interfaces and the desired behaviour ; this approach makes installations and configuration into the target environment almost instantaneously (e.g. maintenance in Operations). Every DEC node configuration can be kept under configuration control in order to build the dedicated installers.

The DEC installer naming file is generated to avoid ambiguity and bring information regarding the node they apply to. Below there are some few examples to illustrate the naming conventions to easily identify the installation kit for a given DEC node configuration.

Also the DEC installer can be customised to carry or avoid specific SW items, such as the testing tools (i.e. unit tests, interface tests, etc). The installation kit referred below as example has been customised for some Sentinel-2 project to carry the test tools, the OData tools and make usage of postgresql to persist the operations performed

As a very quick summary, users of the SW are encouraged to delegate the creation of the configuration by providing the requirements / interface documents to build dedicated installation packages for every node.

# Uninstall DEC SW

In order to uninstall DEC SW, execute the following command in the shell:

    Remove executables:
    decValidateConfig, decCheckConfig, decCheckSent, decConfigInterface2DB, decDeliverFiles, decGetFiles4Transfer, decGetFromInterface, decListener, decManageDB, decNotify2Interface, decSend2Interface, decSmokeTests, decStats, decUnitTests, decUnitTests_IERS, decUnitTests_ncftpput, decUnitTests_mail

    in addition to the gem? [Yn]

Press 'Y' key to remove the executables as well

[]{#COTS label="COTS"} []{#FOSS label="FOSS"}

# FOSS Required

This section enumerates the FOSS which are used by DEC SW for exchange of file by some network protocol implementation, or file transformations associated to those exchanges.

This manual, which currently address component level information, does not address how to provision these COTS ; they can be obtained naturally with most OS distribution, downloaded with its native package manager, or manually installed. However it is noted that DEC containerized execution environments definition (IaaS) which already resolve every SW COTS dependencies out of the box are available, please do not hesitate in requesting information.

## Databases

This section enumerates the different databases which can be used by DEC SW. Only *sqlite3* is *mandatory* to allow the execution of the entire set of *unit tests*. Below the different databases that have used at some deployment. It is recalled that it is possible to execute the DEC SW without any database by usage of flag *\"--nodb\"*.

-   [*sqlite3*](https://www.sqlite.org) : is an in-process library that implements a self-contained, serverless, zero-configuration, transactional SQL database engine

-   [*PostgreSQL*](https://www.postgresql.org/) : object-relational database system with a strong reputation for reliability, feature robustness, and performance

-   [*MySQL*](https://www.mysql.com/) : a high performance, scalable database management system

## Network Tools

This section enumerates the network tools which are used by DEC SW.

-   [*ncftp*](https://www.ncftp.com) : application programs implementing the File Transfer Protocol (FTP)

-   [*sftp*](https://www.openssh.com) : application programs implementing the Secure File Transfer Protocol (SFTP)

-   [*sshpass*](https://linux.die.net/man/1/sshpass): application to handle the SSH password in non interactive mode (SFTP)

-   [*curl*](https://curl.haxx.se) : command line tool and library for transferring data with URLs (WebDAV)

## File Compression Tools

This section enumerates the file compression tools which can be used by DEC SW.

-   [*7-zip*](https://www.7-zip.org/) : is a file archiver with a high compression ratio ; name of the package can be *\"p7zip\"*

-   [*zip* / *unzip*](http://infozip.sourceforge.net) : provide free, portable, high-quality versions of the *Zip* and *UnZip* compressor-archiver utilities

-   [*gzip*](https://www.gzip.org) : The *gzip* reduces the size of the named files using Lempel--Ziv coding (LZ77)

-   [*compress*](http://man7.org/linux/man-pages/man1/compress.1p.html) : The *compress* utility reduces the size of the named files by using adaptive Lempel-Ziv coding algorithm

## File Transformation Tools

This section enumerates the file transformation tools which can be used by DEC SW.

-   [*xmllint*](http://xmlsoft.org/xmllint.html) : is a command line XML parser which is part of the [*libxml2*](http://xmlsoft.org) and libxml2-utils packages.

-   [*jq*](https://stedolan.github.io/jq/) : jq is a lightweight and flexible command-line JSON processor.

## Encryption Tools

DEC SW makes usage of [*openssl*](https://www.openssl.org/) toolkit to support the encryption of sensible configuration items. The version installed of openssl needs to support the algorithm PBKDF2.

# Installation Verification

## Verification with Unit Tests

This section describes how to execute the *unit tests*, which have been designed to be transparent and harmless in front of the potential different execution environments (i.e. development, integration, production), being their execution a simple and effective manner to verify the correct installation of the DEC SW.

The prerequisites to be able to successfully execute the *unit tests* are :

-   an OS user *dectest*

-   SFTP server running on *localhost* allowing login to *dectest* using the SSH keys

-   FTP server running on *localhost* allowing login to *dectest* using the *password* *dectest*

The results of the unit test should show no failures neither errors ; the execution time in a 2.66 GHz Intel Core 2 Duo is about 10 minutes approximately.

    .
    Finished in 590.39725 seconds.
    <@\textcolor{green}{-----------------------------------------------------------------------------------------------------------------------------------------------------------}@>
    17 tests, 112 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
    100% passed
    <@\textcolor{green}{-----------------------------------------------------------------------------------------------------------------------------------------------------------}@>
    0.03 tests/s, 0.19 assertions/s

## Verification with Operational Interface

This section describes how to verify the correct installation of DEC SW by execution of a test with the IERS *operational* service, for which Internet connectivity is required for the FTP protocol. Note that it is not possible to ensure the connectivity availability by such service and sometimes test may fail by reply of *530 connect failed: Address already in use. No response from server.*

    .
    Finished in 54.38868 seconds.
    <@\textcolor{green}{-----------------------------------------------------------------------------------------------------------------------------------------------------------}@>
    2 tests, 25 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
    100% passed
    <@\textcolor{green}{-----------------------------------------------------------------------------------------------------------------------------------------------------------}@>
    0.02 tests/s, 0.33 assertions/s 

In case of deployment without any database, the tests can be restricted to the ones which make usage of the *\"--nodb\"* execution option:

    .
    Finished in 54.38868 seconds.
    <@\textcolor{green}{-----------------------------------------------------------------------------------------------------------------------------------------------------------}@>
    1 tests, 18 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
    100% passed
    <@\textcolor{green}{-----------------------------------------------------------------------------------------------------------------------------------------------------------}@>
    0.02 tests/s, 0.23 assertions/s

# DEC App Container

It is not strictly in the scope of this reference manual to describe the different integration and deployment strategies to make usage of the DEC SW. However it is considered valuable to document that the SW is ready for containerization (i.e. docker containers) and that such deployment strategy has been successfully used to design full standalone nodes including also standard TCP/IP servers to hub all the interface connections. In this respect there are available some dockerfiles IaaS to define the node SW dependencies in different execution environments (i.e. IVV, Production).

The files to be pushed or the files pulled to be made available to the end-peers are usually exchanged in the host which runs the container. Hence the execution of the DEC App container needs some mount point in the host ; this aspect is managed seamlessly by the different SW handling containers execution (i.e. docker, kubernetes, podman).

The DEC SW can be managed from the command line interface as it were natively installed in the host. As such the command reference of this manual can be used by just pointing to the DEC container by some alias definition invoking the execution for which the execution arguments are naturally appended:

    alias decCheckConfig='podman exec dec decCheckConfig'
    alias decConfigInterface2DB='podman exec dec decConfigInterface2DB'
    alias decDeliverFiles='podman exec dec decDeliverFiles'
    alias decGetFromInterface='podman exec dec decGetFromInterface'
    alias decListDirUpload='podman exec dec decListDirUpload'
    alias decListener='podman exec dec decListener'
    alias decManageDB='podman exec dec decManageDB'
    alias decNATS='podman exec dec decNATS'
    alias decSend2Interface='podman exec dec decSend2Interface'
    alias decStart='podman run --userns keep-id --env '\''USER'\'' --add-host=nl2-s-aut-srv-01:172.23.253.16 --network=host --tz=Europe/London --name dec -d --mount type=bind,source=/data,destination=/data localhost/dec_naos-test_gsc4eo_nl2-u-moc-srv-01:latest'
    alias decStats='podman exec dec decStats'
    alias decTestInterface_CelesTrak='podman exec -i dec decTestInterface_CelesTrak'
    alias decTestInterface_NAOS_IVV-0500='podman exec -i dec decTestInterface_NAOS_IVV-0500'
    alias decTestInterface_NASA='podman exec -i dec decTestInterface_NASA'
    alias decValidateConfig='podman exec dec decValidateConfig'
