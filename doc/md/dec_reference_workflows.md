# Description

This section brings some typical workflow reference common to most use cases of the software.

# Configuration workflow

This section comprises the typical actions to configure every DEC SW node. It assumes a correct installation of the DEC SW include the dependencies referred in this document. Configuration wise it is recommended to get an installation which already carries the definition of the workflows; however configuration can be changed in hot at any point following the information of this manual.

Every command verifies the execution environment to check whether the FOSS SW dependencies are available for usage, in case of missing any of them, the error message [DEC_799](#DEC799) is raised. This explanation applies to every command and it is not duplicated in the document.

## Validate Configuration

The DEC SW configuration items are spread out in different XML files. This steps aims to verify the syntax and semantic correctness of the such configuration as prerequisite of successful operations. This step is performed by [decValidateConfig](#decValidateConfig). This step is to be performed manually from the command line interface whenever is needed (e.g. new SW update carrying modified configuration).

### Check XML Configuration

-   [DEC_002](#DEC002) : the configuration file verifies the settled XML schema

-   [DEC_798](#DEC798) : the configuration is not according to the settled XML schema

## Create DEC Inventory

This step is required to persist and record the circulation operations in a database ; note that it is still possible to perform circulations without persistence of the operations by usage of the \"--nodb flag\" by the different commands. Skip this step if the DEC SW was already previously installed and it is a SW update.

Firstly the database tables are created using [decManageDB](#decManageDB) ; then the interfaces defined in the XML configuration files are populated into the database using [decConfigInterface2DB](#decConfigInterface2DB).

### Drop DEC Inventory

### Create DEC Inventory

[DEC_000](#DEC000) : creation of the DEC DB / Inventory

### Populate Interfaces into DEC Inventory

[DEC_001](#DEC001) : Interface added into the DEC DB / Inventory

## Check Interface Configuration

This step exploits the interface according to the configuration to check the availability of defined end-points (e.g. directories for file based protocols). It also covers the verification of the DEC/Inventory availability if used.

### Check Interface Connectivity

-   [DEC_003](#DEC003) : Interface is correctly declared in DEC/Inventory

-   [DEC_004](#DEC004) : Interface exchange point is reachable

# Pull workflow

## Manual Pull Workflow

This section covers the manual workflow by explicit CLI invoke to execute the pull workflow for a given interface.

### List available data

-   [DEC_005](#DEC005) : Interface polling is started

-   [DEC_105](#DEC105) : File is available

-   [DEC_060](#DEC060) : Number of files available

-   [DEC_100](#DEC100) : Interface pull iteration completed

### Pull available data

-   [DEC_005](#DEC005) : Interface polling is started

-   [DEC_060](#DEC060) : Number of files available

-   [DEC_110](#DEC110) : File is downloaded

-   [DEC_100](#DEC100) : Interface pull iteration completed

### File conversion

-   [AUX_001](#AUX001) : File has been converted

## Automation Pull Workflow

This section cover the automation workflow to pull data from an interface. It leverages the mechanisms described in previous section regarding manual pull workflow.

### Automation Listeners Start

[DEC_006](#DEC006) : Starting automation listener for some interface

### Automation Listeners Status

[DEC_003](#DEC003) : Status of the automation listener for some interface

### Automation Listeners Stop

-   [DEC_002](#DEC002) : Automation listener for some Interface is stopped

-   [DEC_603](#DEC603) : Automation listener for some Interface was not running

# Push workflow

## Retrieve from an archive

This step performed by command using [decGetFiles4Transfer](#decGetFiles4Transfer) gathers every file which will be subject of circulation from [SourceDir](#SourceDir) or a single directory source and places it into every interface [LocalOutbox](#LocalOutbox) appending the sub-directory name according to the delivery protocol (i.e. \"sftp\", \"ftp\", etc).

### Fetch Outgoing Files

-   [DEC_211](#DEC212) : File has been placed at the GlobalOutbox from the [SourceDir](#SourceDir)

-   [DEC_212](#DEC212) : Fetched file has been removed in the [SourceDir](#SourceDir)

-   [DEC_213](#DEC213) : File has been placed into the [LocalOutbox](#LocalOutbox) out-tray.
