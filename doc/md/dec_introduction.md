# Purpose & Scope

The Data Exchange Component (DEC) is a SW component to gather, transform, circulate, archive and publish files autonomously among different *interfaces* and *consumers*.

The scope of DEC SW usually lies on the different ICD defined for communication and exchange of data (generally *files*). As such, it relies on different COTS to delegate the implementation of various network protocols supported.

The DEC SW offers a command line interface to *pull* and *push* files towards the different configured interfaces.

![image](DEC_Context_Diagram.png)

# Definitions

This section addresses a high level overview for the main design drivers that allows DEC to interface efficiently for the configured exchanges:

-   *Interface* : this term beyond the general meaning is usually used to refer to a SW configuration item with such name which includes all the information to perform the circulations (e.g. hostname, credentials, protocol, etc).

-   *Circulation* : this term generally refers to any exchange of files either for retrieval upon *pull* from or for distribution upon *push* to any configured interface.

-   *Dissemination* : this term refers to the file-system local distribution into the Intray(s) of the files previously downloaded from a given interface as part of a *pull* circulation.

-   *Download* : this term is used to refer to the actual retrieval of file from a given interface during a *pull* iteration.

-   *Intray* : the final destination directory for downloaded files upon complete dissemination according to the rules.

-   *Pull* : this term refers to the circulation operation for filtering and listing up to the actual download of files from a given interface according to the configured rules.

-   *Push* : this term refers to the circulation operation to upload the available file(s) in some interface.

-   *Rule* : this generic term refers to the configuration items for *pull* files, *disseminate* them, and *push* them.

# Main Features

This section enumerates a high level overview for the main features that allows DEC to interface efficiently for the configured exchanges:

-   *Automation* : the ability to perform unattended autonomous circulation operations.

-   *Flexibility* : the ability to *pull* & *push* files from configurable interfaces and configurable circulation rules

-   *Interface-Isolation* : every Interface is handled by separated isolated process avoiding any error propagation.

-   *Robustness* : this is to perform "atomic" operations during file circulation ; the state for each operation is always known being network errors tolerant.

-   *Performance* : parallelism of the circulation to fruit the available network bandwidth, support of file compression mechanisms to reduce the footprint of transfers and local dissemination for which duplication of files by *cp* or *mv* can be avoided by usage of *hardlinks*

-   *Resiliency* : to *autonomously* recover from network errors, downtime and eventual glitches and resume operations during every iteration.

-   *Zero-copy* : to avoid new copies in the file system during *dissemination* circulations.

-   *Interfaces configuration management* : flexible CI/CD chain to create dedicated SW installation kit to carry specific desired interfaces configuration ready for operation.

-   *Comprehensive traceability* : complete deterministic and unambiguous traceability along the entire workflow using codes within the log file of every operation.
