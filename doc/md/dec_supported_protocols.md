# Network Protocols for Pull

## Introduction

This section introduces to the different network protocols & associated verbs which are supported for pull circulations:

-   **Local**

-   **SFTP**

-   **FTP**

-   **FTPS**

-   **HTTP**

-   **WebDAV**

-   **OData**

## Local

The files from the [*DownloadDirs*](#DownloadDirs) are pulled using the OS file management operations. The files *\"downloaded\"* into the [*LocalInbox*](#LocalInbox) is perfomed using the [POSIX](#https://en.wikipedia.org/wiki/POSIX) [hard-link](#https://en.wikipedia.org/wiki/Hard_link) operation whenever both configuration items point to the same file-system, otherwise a copy is perfomed.

## SFTP

Secure File Transfer Protocol over SSH is supported. Authentication supported modes are passwordless with SSH keys and using the password.

If no password is configured in the interface definition, the interface handler relies on the identity management SSH keys configuration to perform password-less authentication before triggering batch / non-interactive pull requests to the interface. In this respect configuration-wise, the SSH keys are not included in the SW installation package and need to be set.

## FTP

The files from the [*DownloadDirs*](#DownloadDirs) are pulled using the File Transfer Protocol. It supports both PORT and PASV connections for the TCP data stream which carries the files pulled. Transfers are enforced in BINARY mode (i.e. ASCII transfer mode is not used). The FTP commands RETR and optionally DELE are used respectively to perform the file retrieval and its deletion in the server.

## FTPS

Plain FTP and TLS / SSL Actually for FTPS the DEC SW implements two different handlers

## HTTP(S)

The protocol HTTP(S) is not strictly a file based one, however files can be published using it and DEC SW is able to pull them. The handler works in two different modes driven by the [*DownloadDirs*](#DownloadDirs) configuration, either by retrieval of a fixed URL, either using the URL to search for files for retrieval.

### Fixed URL

The handler retrieves with HTTP GET the URL, which is defined by the [*DownloadDirs*](#DownloadDirs) in the \"Directory\" item prepended by the [*Server*](#Config_Server) Server [*Hostname*](#Hostname) configuration item; some data providers use this strategy to publish up-to-date data at a fixed location (e.g. below):

        <Directory DepthSearch="0">/iers/bul/bulc/Leap_Second.dat</Directory>

### Directory Emulation

The protocol handler detects the trailing symbol slash in the Directory configuration item defined as part of the [*DownloadDirs*](#DownloadDirs). Then it processes the HTML received ; the logic of processing is arbitrary which is to retrieve all HTML *'href'* anchors which are then nominally filtered according to the DEC configuration for such interface (cf. [*DownloadRules*](#DownloadRules)). This handler depends on the interface implementation since this is *not* protocol independent as the WebDAV extensions. Hence this handler needs to be verified case by case. In general this is a dirty solution when WebDAV cannot be available on top of HTTP.

## WebDAV

The protocol WebDAV is built on top of HTTP with some specific extensions which allows to search and find items meeting some criteria. The WebDAV protocol handler uses the verb PROPFIND to obtain the items published for every Directory in [*DownloadDirs*](#DownloadDirs) and then those are filtered according to the [*DownloadRules*](#DownloadRules). The final retrieval of the selected items according to configuration is performed by the HTTP handler using the verb GET.

## OData

The protocol [OData](https://docs.oasis-open.org/odata/odata/v4.01/odata-v4.01-part1-protocol.html) is supported ; in particular for DIAS interfaces, which make available an [API](https://scihub.copernicus.eu/userguide/ODataAPI) to query and obtain metadata or / and finally download the selected items driven by the previous queries. A dedicated client The protocol handler detects the trailing symbol slash in the Directory configuration item defined as part of the [*decODataClient*](#decODataClient) is devoted for this kind of interfaces to perform selection by sensing time or availability time of the data.

## NATS

### Request-Reply

NATS [request-reply](https://docs.nats.io/nats-concepts/core-nats/reqreply) pattern is supported ; DEC performs NATS request according to some API configuration and it processes the received reply.

### Subscribe

NATS [publish-subscribe](https://docs.nats.io/nats-concepts/core-nats/pubsub) pattern is supported ; DEC subscribes to some subjects according to some API configuration to asynchronously receive the messages for their processing.

# Network Protocols for Push

## LOCAL

PUT

## SFTP

PUT

## FTP

PUT

## HTTP

PUT

## WebDAV

The WebDAV extension of [HTTP](https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html), which is defined in [RFC4918](https://tools.ietf.org/html/rfc4918) allows to rename files so that DEC can make them visible just upon complete upload.

Initially the file is uploaded into the [*UploadTemp*](#UploadTemp) using the HTTP verb PUT. Upon its successful upload the file is *moved* into the final [*UploadDir*](#UploadDir) using the verb MOVE of the WebDAV extension.
