# Log4r Configuration

The log capability by DEC SW are based on the *ruby* [Log4r](http://log4r.sourceforge.net/rdoc/files/log4r/configurator_rb.html) capabilities, which is a porting of the widely spread Java library Log4j.

The associated configuration file *dec_log_config.xml* is not DEC SW specific and it can be directly handled by *log4r* and can be similar to other components which use the same logging *Log4r* library.

## Rolling File Outputter

This section recalls the [Log4r](https://www.rubydoc.info/github/bestmike007/log4rails/Log4r/RollingFileOutputter) *RollingFileOutputter* which is used by default in DEC SW.

-   *type* : RollingFileOutputter

-   *filename* : pull path filename

-   *formatter* : [PatternFormatter](https://www.rubydoc.info/github/bestmike007/log4rails/Log4r/PatternFormatter)

-   *trunc* : If true, deletes the existing log files, otherwise continues logging where it left off last time

-   *maxsize* : Maximum size of every log file in bytes

-   *max_backups* : Maximum number of prior log files kept

-   *maxtime* : Maximum age of every log file in seconds

## Server

The *Server* configuration item defines the parameters which rule the network protocol of choice selected to rule the file circulations either in *pull* and *push* mode.

# Example dec_log_config.xml

    <log4r_config>

       <pre_config>
          <parameter name="mainLoggerName" value="NODE_1"/>
       </pre_config>

       <outputter name="console"  level="INFO" >
          <type>StdoutOutputter</type>
          <formatter type="Log4r::PatternFormatter" pattern="[%5l] %d %c.#{moduleName} - %m">
          <date_pattern>%Y-%m-%d %H:%M:%S</date_pattern>
          </formatter>
       </outputter>

       <outputter name="dec_log" level="DEBUG">
          <type>RollingFileOutputter</type>
          <filename>/tmp/DEC.log</filename>
          <formatter type="PatternFormatter" pattern="[%5l] %d %c.#{moduleName} - %m">
          <date_pattern>%Y-%m-%d %H:%M:%S</date_pattern>
          </formatter>
          <trunc>false</trunc>
          <maxsize>10000000</maxsize>
          <max_backups>4</max_backups>
          <maxtime>2592000</maxtime>
       </outputter>

       <logger name="NODE_1" level="DEBUG" trace="false">
          <outputter>console</outputter>
          <outputter>dec_log</outputter>
       </logger>

    </log4r_config>
