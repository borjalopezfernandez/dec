::: description
Answer: DEC documentation *is* code and it is treated accordingly ; as such, SW updates are never committed in the development repository without their documentation updates ensuring a proper alignment. The pdf document is generated with a rake task, and thus it propagates a generation time (i.e. daily basis). For document management purposes, the SW version it applies plus the document generation date is the general key.

Answer: There is no restriction in the number of Interfaces configured in a given node.

Answer: Using the DEC gem, the restriction is associated to the ruby run-time environment; in the installation information it is strongly recommended to include the ruby run-time environment associated to each OS user who will execute the SW in opposition to the usage of the OS common run-times (e.g. /usr/local/lib /opt/lib, etc). In this respect the run-time execution isolation principle is met and different OS user with their app / services can execute different DEC nodes for their specific purposes.

Answer: All DEC SW dependencies rely on maintained SW. The implementation of the different protocol handlers is independent, and therefore can rely on different SW dependencies. The handler of the plain FTP protocols is based on some initial legacy SW which has been updated to deal with obsolescence so the ncftp SW has been maintained for the time being despite the extensive usage of curl in other different protocol handlers.

Answer: log message [DEC_110](#DEC110) carries the size of every file pulled.

::: scriptsize
    [ INFO] 2021-10-08 15:55:39 SBOA.pull - [DEC_110] I/F HUB: foo downloaded with size 107295 bytes
    [ INFO] 2021-10-08 15:58:02 SBOA.pull - [DEC_110] I/F HUB: boo downloaded with size 1245 bytes
    [ INFO] 2021-10-08 15:58:02 SBOA.pull - [DEC_110] I/F HUB: moo downloaded with size 17106 bytes
:::

Answer: log message [DEC_210](#DEC210) carries the size of every file pulled.

::: scriptsize
                    [ INFO] 2021-10-08 15:55:39 SBOA.push - [DEC_210] I/F NAV: finals.all UPLOADED / size 11 bytes
                    [ INFO] 2021-10-08 15:58:02 SBOA.push - [DEC_210] I/F NAV: tai-utc.dat UPLOADED / size 12 bytes
:::

Answer: There is no restriction in the protocols supported, which can be enlarged by the implementation of dedicated protocol handlers. Standard protocols such as HTTP can publish data by URLs which are not necessarily liaised to files. Also there are other protocols specialising HTTP with dedicated API / end-points, which are not file-based (e.g. OASIS Open Data Protocol / OData). Upon performing the pull request and obtaining the data, then DEC flushes the retrieved data into files to feed the consumers.

Answer: There is no restriction in the protocols supported, which can be enlarged by the implementation of dedicated protocol handlers. Standard protocols such as HTTP can receive data at URLs, which are not necessarily liaised to files by usage of POST requests ; these are tailored for the interface end-point definition (i.e. parameters part of the request).

Answer: Such lack of information is a gap of this document which needs to be addressed. A quick reply is that the DEC SW needs for resources is really negligible. As example it is mentioned one use-case in the IoT domain using a low power ARM platform with 512MB RAM (cf. *raspberry pi*) to gather [local meteorological data](http://meteoleoncarmenes.altervista.org) and systematically push it for consumption.

Answer: The location of the configuration files can be obtained using the following command using the Debug flag:

     [DEBUG] xmllint --schema
     /home/s2ops/.frum/ruby/gems/dec-1.0.24/code/dec/../../schemas/dec_interfaces.xsd
     /home/s2ops/.frum/ruby/gems/dec-1.0.24/code/dec/../../config/dec_interfaces.xml --noout

Answer: No, this functionality was historically implemented to alert the outgoing files towards external whereas pull is already under the control of the SW workflow (e.g. availability of a report file with the files pulled). If there is a use-case, it is fairly straight-forward to expand the functionality to support also email notifications for pull operations.

Answer: If you are interested in the interface tests or / and the DEC SW associated configuration for their exploitation, please ensure that installation package carries them (i.e. in general the installation file carries the \"test\" name) to ensure both test tools and configuration are included. Just ask for them $\ddot\smile$ .

Answer: space-track.org asks for a fair usage of their interface to control the bandwidth costs and the pull operations using cURL are limited by using '--limit-rate 100K' according to their API recommendation.

Answer: Documentation is handled as code in the repository. The document is compiled so far with no frills or appealing style templates but the essential in order to keep compatibility when converting to some content managers such as Wiki or Atlassian Confluence as example.
:::
