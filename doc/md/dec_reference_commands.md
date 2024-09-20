[\[CLI\]]{#CLI label="CLI"}

Command Line Interface
======================

This section provides a brief description of the command line interface
which is common to every DEC SW executable.

The command exit codes have been defined in order to chain them at will
so it is possible to understand their execution correctness. In this
respect the following exit codes are available:

-   *exit 0* : the command was successfully executed .

-   *exit 66* : the command was invoked with wrong parameters and it did
    not perform its workflow.

-   *exit 99* : this command was executed and raised any problem when
    performing its workflow.

[\[decValidateConfig\]]{#decValidateConfig label="decValidateConfig"}

decValidateConfig
=================


    == Synopsis
        
    This is a DEC command line tool that checks the validity of DEC configuration
    files according to DEC's XSD schemas. This tool should be run everytime a 
    configuration change is performed.

    -e flag:

    With this option the Interfaces (Entities) configuration file (dec_interfaces.xml)
    is validated using the schema interfaces.xsd

    -g flag:

    With the main DEC configuration file (dec_config.xml)
    is validated using the schema dec_config.xsd

    -i flag:

    With this option the Incoming file-types configuration file (dec_incoming_files.xml)
    is validated using the schema dec_incoming_files.xsd

    -o flag:

    With this option the Outgoing file-types configuration file (dec_outgoing_files.xml)
    is validated using the schema dec_outgoing_files.xsd

    -m flag:

    With this option the DEC Mail configuration file (ft_mail_config.xml) is
    validated using the schema ft_mail_config.xsd

    -l flag:

    With this option the DEC Logs configuration file (dec_log_config.xml) is
    validated using the schema dec_log_config.xsd

    -a flag:

    This is the all flag, which performs all the checks described before.


    == Usage
    -a          Check all DEC configuration files
    -g          Check DEC's general configuration file dec_config.xml
    -e          Check the Entities Configuration file dec_interfaces.xml
    -m          Check the mail configuration file ft_mail_config.xml
    -i          Check the incoming file-types configuration file dec_incoming_files.xml
    -i          Check the outgoing file-types configuration file dec_outgoing_files.xml
    -X <dir>    eXtract the configuration into the specified directory
    -N <label>  label of the node to be appended into the configuration
    -h          shows this help
    -v          shows version number


        

[\[decCheckConfig\]]{#decCheckConfig label="decCheckConfig"}

decCheckConfig
==============

    == Synopsis

    This is a command line tool that checks the coherency of the DEC configuration.
    DEC configuration is distributed amongst different XML files. The information set up
    must be coherent. This tool ensures that all configuration critical elements are correct.
    (All DEC config files must be placed in the $DEC_CONFIG directory). 
    So, run this tool everytime a configuration change is performed.

    -e flag:

    With this option the Interfaces (Entities) configuration placed in dec_interfaces.xml
    is checked. As well it is checked the coherency between the dec_interfaces.xml
    configuration file and the DEC Inventory (DEC Database).
    (Note: if the network link to a given I/F is broken, the tool will not be able to connect and it
    will report a configuration error of this I/F).


    -i flag:

    With this option the Incoming file-types registered in the dec_incoming_files.xml are checked.
    Mainly what it is done is to check that the interfaces from a File is retrieved are configured in 
    the dec_interfaces.xml file.


    -m flag:

    With this option the DEC Mail configuration placed in the ft_mail_config.xml is checked.


    -s flag:

    With this option the DCC Services configured in the dcc_services.xml file are checked.
    The check performed with this flag is that the executable set in the command of the service
    can be found in the $PATH environment variable.


    -t flag:

    With this option the In-Trays configured in the dec_incoming_files.xml file are checked.


    -a flag:

    This is the all flag, which performs all the checks described before.


    == Usage
    decCheckConfig [--nodb]
    -a    checks all DEC configuration
    -e    checks entities configuration in dec_interfaces.xml
    --nodb no Inventory checks
    -i    checks incoming file-types configured in dec_incoming_files.xml
    -o    checks outgoing file-types configured in dec_outgoing_files.xml
    -m    checks the mail configuration placed in ft_mail_config.xml
    -t    checks the In-Trays configuration placed in dec_incoming_files.xml
    -l    checks the log configuration
    -h    it shows the help of the tool
    -u    it shows the usage of the tool
    -v    it shows the version number
    -V    it performs the execution in Verbose mode
    -D    it performs the execution in Debug mode     

   

decCheckSent {#decCheckSent}
============

    == Synopsis

    This is a DEC command line tool that lists the contents of the <Upload> directory
    corresponding to a given interface configured in interfaces.xml

    == Usage
    decCheckSent -m <Interface_Name> [-t]
    --mnemonic  <MNEMONIC> (mnemonic is case sensitive)
    --temp      it shows the content of the <UploadTemp> directory
    --Show      it shows all available I/Fs registered in the Inventory
    --help      shows this help
    --usage     shows the usage
    --Debug     shows Debug info during the execution
    --version   shows version number


[\[decConfigInterface2DB\]]{#decConfigInterface2DB
label="decConfigInterface2DB"}

decConfigInterface2DB
=====================

    == Synopsis

    This is a Data Exchange Component command line tool that synchronizes the Entities configuration file
    with DEC Inventory. It extracts all the I/Fs from the dec_interfaces.xml file and 
    inserts them in the DEC Inventory.

    As well it allows to specify a new I/F mnemonic to be loaded into the DEC Inventory with 
    the "--add" command line option.

    == Usage
    decConfigInterfaceDB --add <MNEMONIC> | --process EXTERNAL
    --add <MNEMONIC>     (mnemonic is case sensitive) add the specified Entity  
    --process EXTERNAL   process $DEC_CONFIG/dec_interfaces.xml
    --Show               it shows all I/Fs already loaded in the DCC Inventory
    --Verbose            execution in verbose mode
    --version            shows version number
    --help      shows this help
    --usage     shows the usage

   

decDeliverFiles {#decGetFiles4Transfer}
===============

decGetFiles4Transfer
====================


    == Synopsis

    This is a DEC command line tool that retrieves files to be transferred (push)
    from a source directory specified by $DEC_DELIVERY_ROOT environment variable.

    Files present in the source directory are filtered according to the rules 
    defined in ft_outgoing_files.xml
    => wildcards such as  <File Type="S2A*">
    => children directories, such as <File Type="GIP_PROBA2"> 

    Files gathered are finally placed into the directory defined in the 
    configuration <GlobalOutbox> present in dec_config.xml 

    -O flag:
    The "ONCE" flag registers in the Inventory all the files sent. As well it checks
    prior to the delivery whether a files has been previously sent or not to avoid 
    delivering it twice to the same Interface.

    == Usage
    decGetFiles4Transfer [-O] [-l]
    --ONCE      The file is just sent once for each I/F
    --list      list only
    --help      shows this help
    --usage     shows the usage
    --Debug     shows Debug info during the execution
    --version   shows version number

   

decGetFromInterface
===================


    decGetFromInterface 

    == Synopsis

    This is a DEC command line tool that polls the I/Fs for retrieving 
    files of registered filetypes. As well It retrieves the I/F 
    exchange directory file content linked to a time-stamp.

    -l flag:

    With this option, only "List" of new availables files for Retrieving and Tracking is done.
    This flag overrides configuration flags RegisterContentFlag RetrieveContentFlag in dec_interfaces.xml
    So Check ONLY of new Files is performed anyway.

    -R flag:

    With this option (Reporting), DEC Reports will be created (see dcc_config.xml). 
    Report files are initally placed in the Interface local inbox and
    if configured in files2InTrays.xml disseminated as nominal retrieved file.

    --del-unknown:

    It overrides the dcc_config.xml configuration parameter DeleteUnknown and explicitly
    commands for removal of unknown files not configured in ft_incoming_files.xml


    == Usage
    decGetFromInterface -m <MNEMONIC>  [-l] [--nodb]
    --mnemonic  <MNEMONIC> (mnemonic is case sensitive)
    --list      list only (not downloading and no ingestion)
    --nodb      no Inventory recording
    --no-intray skip step of delivery to intrays
    --del-unknown it deletes remote files not configured in ft_incoming_files.xmls
    --receipt   create only receipt file-list with the content available
    --Report    create a Report when new files have been retrieved
    --Show      it shows all available I/Fs registered in the DEC Inventory
    --help      shows this help
    --usage     shows the usage
    --Debug     shows Debug info during the execution
    --Unknown   shows Unknown files
    --Benchmark shows Benchmark info during the execution
    --version   shows version number

    

decODataClient {#decODataClient}
==============

    The decODataClient is a simple OData client to hit Copernicus Sentinel
    servers to extract metadata and download the associated products.

    DHUS queries:

    Query by Sentinel-2 Datatake Identifier: which looks for the associated
    published Complete Single Tile products 

    --query dhus:s1:S1B
    --query dhus:s2:S2A
    --query dhus:gnss:S1B
    --query dhus:s2:GS2B_20200903T104429_018252_N02.14
    --query dhus:s1:S1A:S1A_EW_GRDM
    --query dhus:s1:S1A:45C1F

    --query adgs:s2:S2B

    --query dhus_s5p:s5:S5

    PRIP: queries:

    Query is so far targetting S2PRIP specifically.

    --query prip:S2B_OPER_MSI_L0__DS_VGS2_20201028T163228_S20201028T144729_N02.09:MSI_L0__GR

    The queries can be done also specifically by PDI:
    decODataClient -u <user> -p <pass> -q prip:S2B_OPER_MSI_L0__DS_VGS1_20210126T095435_S20210126T080454_N02.09 -V

    == Usage
    decODataClient 
    --user      <username>
    --password  <password>
    --time       2021-03-24T00:00:00.000 (DHuS format applied to the IngestionDate)
    --delay     <hour delay> (decimal offset 0.5-0.25 is scaled to minutes)
    --sensing   "2021-03-16T00:00:00.000,2021-03-20T00:00:00.000"
    --creation  "2021-03-16T00:00:00.000,2021-03-20T00:00:00.000"
    --H         <hours delay> (decimal offset 0.5-0.25 is scaled to minutes)
    --Location  <full_path_dir>
    --format    json | xml | csv

decListener
===========


    == Synopsis

    This is a Data Exchange Component (DEC) command line tool 
    that manages the I/Fs listeners for data retrieval.

    The DEC listeners automates the file pulling from the configured interface.
    One listener is devoted for every interface configured.

    The behaviour of the listener is driven by the settings defined
    in the configuration file $DEC_CONFIG/dec_interfaces.xml

    Alternatively the listener settings can be overriden with the command line options.

    == Usage
    decListener  --all [-R]| --mnemonic <MNEMONIC> --interval <seconds>
    --all                 starts a listener for each I/Fs
    --Reload              force a Restart of all listeners
    --stop <MNEMONIC>     it stops of the listener for the given I/F
    --Stop                it stops of all listeners
    --check               it checks whether the listeners are running
    --mnemonic <MNEMONIC> (mnemonic is case sensitive)
    --interval            the frequency it is polled I/F given by MNEMONIC (in seconds)
    --nodb                no Inventory recording
    --no-intray           skip step of delivery to intrays upon download
    --help                shows this help
    --Debug               shows Debug info during the execution
    --version             shows version number      

    

[\[decManageDB\]]{#decManageDB label="decManageDB"}

decManageDB
===========


    == Usage
    decManageDB --create-tables | --drop-tables
    --create-tables   create all minarc required tables
    --drop-tables     drops all minarc tables
    --rpf             selector to include reference planning tables
    --Debug           shows Debug info during the execution
    --help            shows this help

[\[decNATS\]]{#decNATS label="decNATS"}

decNATS
=======


    == Synopsis

    This is a command line tool that connects to NAOS MCS CCS5 using NATS, HTTP & SFTP.

    > FSTATUS : Get the status of the CCS5 session 
    decNATS -n NAOS_IVV_MCS_NATS -FSTATUS
    > FSTART  : Start a CCS5 session
    decNATS -n NAOS_IVV_MCS_NATS -FSTART
    > FSTOP   : Stop a CCS5 session
    decNATS -n NAOS_IVV_MCS_NATS -FSTOP


    F0. Get Session 

    F1. Manage G/S connections
    CCS5.AutoPilot.NAOS.call, message: SleGroundStationMgm SVALS0 CONNECT

    F2. Session Switch
    NATS subject used by AUTO to issue the request: CCS5.AutoPilot.NAOS.switch
    NATS body: none.

    F3. Ingest MPS activities file
    NATS subject used by AUTO to issue the request: CCS5.AutoPilot.NAOS.call
    NATS body: Ingest <input URL> <target path>
    <input URL>: path to local file (e.g. NFS mounted) or FTP URL for the file to be ingested, in the latter case the URL must contain user, password, hostname, remote path including a file name (Port is optional).
    <target path>: destination path for the ingested path (absolute or relative directory/file path).
    Note that if the destination path ends with / (slash), it is treated as a directory, and the ingested file will keep its name. Otherwise it is a full path, including a file name.
    Note that when using a relative path, the destination path will be relative to a root folder preconfigured in the MCS for all ingested files (settings: NAOS/IngestDir).

    decNATS -n NAOS_IVV_MCS_NATS -F3 -P "{\"filename\" :\"/tmp/2022-05-25T15:36:59.288624_PLA_SBA\", \"target\" :\"/tmp/2022-06-01T18:00:00.449688_PLA_OSC_eng_uplink\"}"

    F4. Trigger processing of MPS/FDS activities file
    NATS subject used by AUTO to issue the request: CCS5.AutoPilot.NAOS.call
    NATS body: ProcessActivityFile <PATH>
    <PATH>: Path to the MPS/FDS activities XML file (corresponds to <target path> used in the ingest function (F3). The file is written according to the XML schema mtl.xsd (see Appendix 1 – Spacecraft activities file).

    decNATS -n NAOS_IVV_MCS_NATS -F4 -P "{\"path\" :\"/CCS/VARIABLE/INPUTS/2022-05-25T15:36:59.288624_PLA_SBA\"}"
    decNATS -n NAOS_IVV_MCS_NATS -F4 -P "{\"path\" :\"/CCS/VARIABLE/INPUTS/2022-05-27T09:14:38.449688_PLA_OSC\"}"

    F5. Start dispatching a sequence of TCs created from an activities file
    NATS subject used by AUTO to issue the request: CCS5.AutoPilot.NAOS.call
    NATS body: UplinkActivityFile <filename>
    <filename>: name of the activity file that was used to generate the TC sequence (without extension “.xml”)
    This request executes the TC sequence generated in F4 (above), starting the uplink of all TCs in the file. TCs are sent according to the current active commanding mode: either sequential (COP1 active, also known as AD) or expedite (also known as BD).
    If COP1 is active, a command (either a PUS TC(11,4) carrier of a time-tagged TC or an immediate TC) is considered uplinked when the onboard acceptance verification stage succeeds (UV_ONB_ACC, verified with TM/CLCW).
    If COP1 is not active, the relevant stage for considering the TC uplinked is UV_GS_UPLINK (corresponds to the ground station reporting TC being uplinked).
    After a successful uplink, the stack file is deleted, and the NATS reply message is simply “OK”. If uplinking failed at a certain stage, the file will stay on disk, so it does not need to be regenerated again. However, it makes no provisions to avoid sending the same TCs again

    decNATS -n NAOS_IVV_MCS_NATS -F5 -P "{\"filename\" :\"2022-06-25T15:36:59\"}"

    F6. Generate TM report (for FDS)
    NATS subject used by AUTO to issue the request: CCS5.AutoPilot.NAOS.call
    NATS body: HistoryReport <Report Type> <start time> <end time> <outputURL>
    <Report Type>: GPS, THR, SCA, MSC (or other). This value identifies a report configuration file (named <Report Type>.dat), containing the list of TM parameters to be retrieved (PCF_NAME’s).
    <start time> <endtime>: time range for the retrieval (e.g. last orbit), ISO format e.g. 2020-04-20T15:18:49
    <outputURL>: destination of the final report.

    decNATS -n NAOS_IVV_MCS_NATS -F6 -P "{\"type\" :\"GPS\", \"start\" : \"2022-07-06T01:00:00\" , \"end\" : \"2022-07-06T03:00:00\", \"url\" : \"/tmp/IVV_DEC_TM-GPS_20220706T010000_20220706T030000.xml\" }"
    decNATS -n NAOS_IVV_MCS_NATS -F6 -P "{\"type\" :\"THR\", \"start\" : \"2022-07-06T01:00:00\" , \"end\" : \"2022-07-06T03:00:00\", \"url\" : \"/tmp/IVV_DEC_TM-GPS_20220706T010000_20220706T030000.xml\" }"

    F7. Process Playback TM frames
    NATS subject used by AUTO to issue the request: CCS5.AutoPilot.NAOS.call
    NATS body: ReplayTmFrames <File path> <VC>
    <File path> : TM File path (file absolute path, or relative to a preconfigured root folder for ingested files : settings: NAOS/IngestDir)
    <VC> TM VC, filter for TM frames to replay (value: 0, 1, ...7) (optional argument, if not provided all VCs in the file are replayed).
    The input TM file is a binary file of concatenated TM frames where each frame is 1115 bytes long (configurable at general level in CCS5 for the mission via settings: TM/frame/dataLength).
    Frames are read out of the TM file and injected into CCS5 for processing. If synchronization is lost while reading the file (due to file data inconsistency), processing will stop with an error. Injected frames are marked with “source” property set to the file name. This property is propagated to TM packets and parameters and made available as metadata for visualisation (e.g. TM history viewers) and retrieval within the MCS (CCS5).
    The process ends when all frames have been replayed, the caller (AUTO) is eventually notified with a response that includes the number of replayed frames.


    MessageBroker::subscribe -subject CCS5.AutoPilot.NAOS.call.ack referby ackMessage
    trace add variable ackMessage write [lambda {var idx op} {
     syslog -ok "$tcl_name -> Received ACK message: [MessageBroker::getMessageBody $::ackMessage]"
    }]


    == Usage
    decNATS -m <I/F SFTP> -n <I/F NATS> -F<function> -P {JSON parameters}
           --mnemonic  <MNEMONIC> (mnemonic is case sensitive)
           --Subject   <subject>
           --Body      <body>
           --nodb      no usage of the Inventory for recording operations
           --help      shows this help
           --usage     shows the usage
           --Debug     shows Debug info during the execution
           --version   shows version number

    

[\[decNotify2Interface\]]{#decNotify2Interface
label="decNotify2Interface"}

decNotify2Interface
===================


    == Usage
    decNotify2Interface -m <MNEMONIC> --OK | --KO
    --mnemonic  <MNEMONIC> (mnemonic is case sensitive)
    --OK        notify success in the delivery to the I/F -f full_path_filelist list of files send
    --KO        notify failure in the delivery to the I/F -f full_path_filelist list of files failed to be sent
    --help      shows this help
    --usage     shows the usage
    --Debug     shows Debug info during the execution
    --version   shows version number

decSend2Interface
=================


    == Synopsis

    This is a DEC command line tool that deliver files to a given I/F in PUSH mode.
    It delivers files using the configured protocols (s)ftp and email. 
    Files sent can be registered in an Inventory and the delivery date is set to the latest one.

    This command can be used in order to send a given file just once 
    (for each delivery method: ftp, email) for a given Interface. 
    Use "-O" flag to enable this behaviour.

    -R flag:

    With this option (Report), a Report "List" with the new files sent is created. 
    This Report file is initally placed in the Interface local inbox.


    == Usage
    decSend2Interface -m <MNEMONIC> [-O] [--nodb]
    --mnemonic  <MNEMONIC> (mnemonic is case sensitive)
    --ONCE      The file is just sent once for that I/F
    --AUTO      local outbox Automatic management 
    --loops <n> n is the number of Loop retries to achieve the Delivery
    --delay <s> s seconds of delay between each Loop Retry
    [60 secs by default if it is not specified]
    --retries <r>  r is the number of retries on each Loop for each file
    --Report    create a Report with the list of files delivered to the Interface
    --list      list only (not downloading and no ingestion)
    --Nomail    avoids mail notification to the I/F after successfully delivery
    --Show      it shows all available I/Fs registered in the Inventory
    --nodb      no usage of the Inventory for recording operations
    --help      shows this help
    --usage     shows the usage
    --Debug     shows Debug info during the execution
    --version   shows version number

   

decSmokeTests {#decStats}
=============

decStats
========


    == Synopsis

    This is a DEC command line tool that shows file reception statistics  

    == Usage
    decStats
    --Hours <hours>            status of last n hours
    --file <filename>          status of a given filename
    --help                       shows this help
    --usage                    shows the usage
    --Debug                   shows Debug info during the execution
    --version                  shows version number


    

[\[auxConverter\]]{#auxConverter label="auxConverter"}

auxConverter
============


    == Synopsis

    This is a Data Exchange Component (DEC) command line tool that manages the
    file conversions / harmonisation according to every mission standard and 
    mission service providers such as ground stations.

    This tool can be used manually from the command line or included in the DEC
    configuration as part of any pull or push workflow.

    For reference to the current file formant conversions and the auxiliary data
    files supported, please execute the tool with the --version flag.

    == Usage
    auxConverter -m S3 -f <full_path_file> -d <dir>
        --mission <id>    mission identifier
          POD    - Copernicus Sentinel-3 Precise Orbit Determination
          S2     - Copernicus Sentinel-2
          S3     - Copernicus Sentinel-3
          NAOS   - NAOS mission
          KSAT   - Kongsberg Satellite Services
        --version         shows the version number / supported conversions
        --Debug           shows Debug info during the execution
        --help            shows this help

    
