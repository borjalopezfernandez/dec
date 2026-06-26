# Introduction

This section describes the DEC SW tests, whose usage is mainly devoted to ensure the quality of every SW version released, but it also covers some dedicated tests to interface with some data providers.

The Unit Tests can be classified into two main categories, the ones devoted to test the general workflow of the SW and the ones which cover the different protocol handlers and their associated configurations within the SW.

The Unit Tests are the ones which are executed to validate every SW version; in opposition to the interface tests, in particular the ones exploiting public providers whose availability cannot be guaranteed to drive the release of the SW.

The definition of the unit testing environment is so far not covered; would there be some interest to execute the unit tests outside the development environment, this information can be formalised in this document.

The information about the test executions is naturally logged into files according to the configuration as any other operation performed by the SW. For the test units associated to the protocol handlers, every run with different test data is kept in different files for subsequent analysis if needed (e.g. test_pull_sftp_3_files_10GB_3Slots.log); the results of the test runner are usually sufficient for systematic testing purposes such as non-regression.

# Unit Tests

## Workflow

The testing of the DEC workflows and helpers are defined in a single test runner; these are independent with respect to the protocols used for the circulations. This section does not include information on every unit test but their whole execution since this is a pre-requisite to validate every SW version.

## Protocols

In general there is one test runner for every protocol handler which tests pull and push operations. Sometimes, specific protocol configuration are tested in additional test runners which also follow the convention for a specific test for pull (i.e. test_pull) and push (i.e. test_push) circulations respectively.

The tests are usually parametric in terms of: parallel transfers, number of files, size of the files, etc ; in this manner every test case is executed several times according the test parameters.

### FTP

The FTP unit test performs the data transfers using the PORT mode in which the FTP client specifies the TCP ports opened for the server to connect to when pulling and pushing files with FTP GET and PUT respectively.

### FTP Passive

There is a specific test runner for the FTP handler with the usual test_pull and test_push test cases to perform FTP GET and PUT requests respectively in FTP passive mode(cf. [passive mode](#PassiveFlag)).

### FTPS Explicit

The FTPS protocol is the plain FTP application over the SSL/TLS which encrypts the TCP streams ; however the associated interface handler is different than the FTP one and therefore it is subject of dedicated unit tests. The unit tests make usage of a self-signed SSL certificate, hence the authenticity of the server is not verified to avoid the test failure and therefore the associated configuration is used accordingly (cf. [VerifyPeerSSL](#VerifyPeerSSL)).

### FTPS Implicit

Unlike the FTPS which is blah blah blah AUTH TLS TBW

### HTTP

The HTTP unit test performs the data transfers using HTTP HEAD and GET requests for pull mode and HTTP PUT verb for push circulations respectively.

### LOCAL

The LOCAL protocol stands for circulation operations across the file-system, hence not implying explicitly any network transaction. Apriori the circulation operations are hardlinks; however the Interface Handler LOCAL is able to automatically failover operations performed across different file-systems, thus performing a copy in which the availability of the complete file is ensured at the end-point. The tests are performed in the same file-system hence verifying the hardlink circulation operations.

### SFTP

The unit tests for SFTP cover both pull and push circulations.

### SMTP Notifications

### WebDAV

The WebDAV operations are performed on top of the base HTTP protocol. Pull operations are performed using the WebDAV extension PROPFIND request to look for elements according to the configuration. Push operations leverage the MOVE method to ensure the integrity of the push circulations end to end ; incomplete HTTP put could be perfectly handled by the end-peer but this mechanism introduces an additional verification step since it requires that the server has successfully dumped the received data from memory into a file.

### NATS

The DEC SW includes a generic NATS client to perform requests and subscribe to messages (cf. [decNATS](#decNATS)). Such tool has been crafted in the framework of NAOS mission. The protocol NATS is a message oriented application protocol whose implementation is delegated to well-proven libraries in the open source domain. For verification purposes, there is no dedicated unit test but an interface test which exploits [decNATS](#decNATS) and hence it verifies correct usage of NATS request and subscribe messages. The interface test is *decTestInterface_NATS_CCS5*.

# Interface Tests

This sections brings a brief reference to some dedicated interface tests which may be leveraged. The principle is that the general DEC SW unit test capacities can be expanded and tailored with minimum effort to address dedicated interface tests which can also be exploited in IVV and Production environments.

Below the available test runners are listed; some are covered at the annex of this document when addressing the Public Data Providers. But there are also dedicated interface tests whose objective is to verify project dedicated exchanges:

-   **decTestInterface_CelesTrak** : interface test exploiting CelesTrak APIs

-   **decTestInterface_CloudFerro** : dec_s2_test_push_lisboa@e2espm-inputhub.gem node dedicated test of interfaces in the frame of the SBOA service to ESA-ESRIN for Copernicus

-   **decTestInterface_ECDC** : Interface test exploiting some ECDC HTTP resources

-   **decTestInterface_GNSS** : Interface test exploiting ESA GNSS server

-   **decTestInterface_IERS** : Interface test exploiting ftp.iers.org server

-   **decTestInterface_ILRS** : Interface test exploiting EUROLAS Data Center server

-   **decTestInterface_OData_ADGS** : this is a functional interface test to verify the OData Server implementation DEC can support

-   **decTestInterface_OData_DHUS** : Interface test exploiting OData API by Copernicus DIAS (OpenHub)

-   **decTestInterface_NATS_CCS5** : Interface test exploiting NATS NAOS MCS / CCS5

-   **decTestInterface_NASA** : Interface test exploiting NASA CDDIS & MSFC data

-   **decTestInterface_NOAA** : Interface test exploiting NOAA Space Weather Prediction Center server

-   **decTestInterface_S2PRIP** : Interface test exploiting internal ESA Copernicus Production Service for Sentinel-2 mission

-   **decTestInterface_SCIHUB** : Interface test exploiting Copernicus DIAS (OpenHub) bulk catalogue export by HTTP in CSV files

-   **decTestInterface_SPCS** : Interface test exploiting SPCS API for CDM

## Celestrak

This interface test with Celestrak comprises the following data-flows:

-   **TLE** : retrieval of TLE associated to different missions such as DE1, DE2, S2A, S2B updated on daily basis.

-   **TCA** : retrieval of TLE catalogue of objects monitored, which is updated on a daily basis.

-   **SFS** : retrieval of space-weather forecast short-term covering the \"Ap\" and \"F10.7\" indexes, covering 45 days generated on a daily basis.

## NASA

This interface test with NASA comprises the following data-flows:

-   **NBULA** : retrieval of NASA Bulletin A with Earth Rotation Parameters updated on weekly basis.

-   **NBULC** : retrieval of NASA Bulletin C with TAI-UTC correlation and which is only updated by the leap second announcements ; latest is in 2017.

-   **SFL** : retrieval of space-weather forecast long-term covering the \"Ap\" and \"F10.7\" indexes covering updated on monthly basis.

# Integration Tests

There are some specific DEC tests which leverage the DEC CICD chain and testing infrastructure devoted for integration within projects. These tests are not generic but fairly straightforward to produce allowing to verify the interface integration among the service back-ends of the project. This information is included in this document for advise to ask for them if deemed valuable by any project.
