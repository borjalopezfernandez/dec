#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'

begin
   require 'cuc/DirUtils'
rescue Exception
   require_relative '../cuc/DirUtils'
end

begin
   require 'cuc/Log4rLoggerFactory'
rescue Exception
   require_relative '../cuc/Log4rLoggerFactory'
end

begin
   require 'dec/ReadConfigDEC'
rescue Exception
   require_relative 'ReadConfigDEC'
end


module DEC

   include CUC::DirUtils

   @@version = "1.0.46.0"

   ## -----------------------------------------------------------------

   @@change_record = { \
      "1.0.46" =>    "TBW / update to ruby", \
      "1.0.45" =>    "Support for NASA CDDIS with HTTPS\n\
          Event message DEC_131 added to the log", \
      "1.0.44" =>    "Interface test for NOAA-IGRF IGRF-13 coefficients\n\
          Unit test decUnitTests_FTP_PASSIVE   includes testing environment\n\
          Unit test decUnitTests_SFTP_KEYS     includes testing environment\n\
          Unit test decUnitTests_SFTP_PASSWORD includes testing environment", \
      "1.0.43" =>    "Interface test for ESA-GSSC update for VTEC IONEX\n\
          Interface test update for IERS Bulletin B (latest)", \
      "1.0.42" =>    "gem net-ssh & net-sftp upgraded to support OpenSSL 3.0\n\
          Interface test update for NASA MSFC Solar Flux (F10.7)", \
      "1.0.41" =>    "Support to interfaces with custom scripts\n\
          DEC env variables override the configuration attributes shipped with the installer",
      "1.0.40" =>    "MD5 config flag for pull to manage duplications (HTTP/FTPS)\n\
          HTTP handler treats html navigation pages as directories for pull",
      "1.0.39" =>    "Support of SSH commands\n\
          decNATS for NAOS updated\n\
          decListener exit code always set to 0 if command is successful", \
      "1.0.38" =>    "Fix on HTTP HEAD to use VerifyPeerSSL configuration", \
      "1.0.37" =>    "New gem roman-numerals is required\n\
          Support of SFTP authentication with password using sshpass\n\
          Support of SFTP known_host checks disabled for the container build process\n\
          Listener on status message code is fixed", \
      "1.0.36" =>    "LocalDissemination config items required to drive automation decListener", \
      "1.0.35" =>    "Management of duplications with MD5 for HTTP protocol", \
      "1.0.34" =>    "NATS protocol support for NAOS MCS CCS5", \
      "1.0.33" =>    "Update to use ruby 3.x series as interpreter\n\
          User & Pass configuration items now can be kept encrypted",
      "1.0.32" =>    "HTTP handler updated to get only href anchors for SCIHUB", \
      "1.0.31" =>    "Update of the OData client for DHUS to support S5P (s5phub)", \
      "1.0.30" =>    "Generation of pull report files DEC_F_RECV when some file failed retrieval", \
      "1.0.29" =>    "Enhancement to parallelise pull operations\n\
          decODataClient updates:\n\
          > ADGS support (AUXIP)\n\
          > download products from DHUS/OpenHub\n\
          > log messages 257, 259, 260 and 667
          first version of man pages shipped\n\
          zero length files unpresent now raises error [DEC_799]\n\
          InterfaceHandlerFTPS_Implicit now raises error when time-out \n\
          public API now kept under ctc module", \
      "1.0.28" =>    "CUC::CheckerProcessUniqueness rework\n\
          decODataClient update to support DHUS/GNSS API", \
      "1.0.27" =>    "curl --connect-timeout raised to 60 to absorb high latencies\n\
          decODataClient updates:\n\
          > new AVDHUS generated for CreationDate intervals\n\
          > request retries implemented for DHUS",
      "1.0.26" =>    "Patch to delete sucessful download files in FTPS protocol:\n\
          Update of the OData client for DHUS:\n\
          > to query by sensing dates referred to ContentDate/Start\n\
          > to define a configurable delay wrt the catalogue CreationDate
          > to request XML, JSON and CSV", \
      "1.0.25" =>    "VerifyPeerSSL is used by HTTP handlers\n\
          decODataClient support for DHUS / Sentinel-1",
      "1.0.24" =>    "Pull local dissemination chmod robustified for errors", \
      "1.0.23" =>    "Local dissemination upon pull is safely compressed:\n\
          Update of the OData client for S2PRIP to support download of PDI",
      "1.0.22" =>    "WebDAV verb MOVE for push does not carry time-out parameters",
      "1.0.21" =>    "Pull local dissemination chmod robustified for errors", \
      "1.0.20" =>    "Support of WebDAV protocol verbs PUT + MOVE for push circulations", \
      "1.0.19" =>    "FTPS Implicit mode (port 990) support for pull & push mode\n\
          Pull local dissemination Compress 7z-x mode to decompress 7z files\n\
          Escape special characters for user / password credentials",
      "1.0.18" =>    "Update of the OData client for DHUS & S2PRIP to support pagination\n\
          OData client for DHUS to stream to the console the received XML",
      "1.0.17" =>    "Support to push parallelisation driven by ParallelDownload config\n\
          OData client for DHUS supports pagination",
      "1.0.16" =>    "First version of the OData client for DHUS / PRIP for Sentinel-2", \
      "1.0.15" =>    "Support to remote inventory / db different than localhost\n\
          dec_config.xml Inventory config now includes Database_Host & Database_Port items", \
      "1.0.14" =>    "New gems sys-filesystem and nokogiri are required\n\
          Support of HTTP(S) protocol verb PUT for push circulations\n\
          Support of HTTP(S) protocol verb GET for pull directories\n\
          Support of HTTP(S) protocol verb HEAD for checking interface URL\n\
          Migration of FTPS (explicit mode) protocol for pull circulations\n\
          Migration of FTPS (explicit mode) protocol for push circulations\n\
          dec_config.xml Inventory item added for database configuration\n\
          dec_config.xml reshuffle of some configuration items\n\
          dec_interfaces.xml configuration item DeleteFlag removed\n\
          dec_incoming_files.xml config item Switches to handle duplication, unknowns, for each I/F\n\
          dec_incoming_files.xml config item FileList replaced by DownloadRules\n\
          dec_incoming_files.xml config item Execute command for each Intray available in DisseminationRules", \
      "1.0.13" =>    "Support of Pull circulations using HTTP protocol for known URLs\n\
          Support of authentication for HTTP(S) GET and DELETE verbs\n\
          dec_interfaces.xml defines <VerifyPeerSSL> to validate the certificate\n\
          log messages rationalisation and clean-up\n\
          gem now includes the gemfile dependencies for their resolution at installation time", \
      "1.0.12" =>    "Support of WebDAV / HTTP(S) protocol using verbs PROPFIND,GET & DELETE\n\
          for pull mode (dec_incoming_files.xml)\n\
          DEC RetrievedFiles report updated to Sentinels naming convention:\n\
          dec_interfaces.xml replaces \"FTPServer\" with \"Server\" configuration item",
      "1.0.11" =>    "Migration to ActiveRecord 6", \
      "1.0.10" =>    "new dec_config.xml deprecates dcc_config.xml & ddc_config.xml\n\
          new dec_incoming_files.xml deprecates files2Intrays.xml & ft_incoming_files.xml\n\
          new dec_outgoing_files.xml deprecates ft_outgoing_files.xml\n\
          Earth Explorer / Earth Observation file-types are deprecated\n\
          support to multiple log4r outputters\n\
          unit tests updated to verify the PUSH mode to send files",
      "1.0.9"  =>    "decUnitTests support batchmode to avoid prompting for confirmation", \
      "1.0.8"  =>    "decListener command line flags fixed", \
      "1.0.7"  =>    "decManageDB creates an index by filename for all tables", \
      "1.0.6"  =>    "decCheckConfig write checks for UploadDir/UploadDir for non secure FTP", \
      "1.0.5"  =>    "notify2Interface.rb fix sending mail to first address only \n         decCheckConfig shipped in the gem", \
      "1.0.4"  =>    "decValidateConfig shipped with the required xsd schemas", \
      "1.0.3"  =>    "upgrade of rpf module to support ruby 2.x series", \
      "1.0.2"  =>    "commands triggered by reception events are now logged", \
      "1.0.1"  =>    "decStats -H <hours> has been integrated", \
      "1.0.0"  =>    "first version of the dec gem installer created" \
   }
   ## -----------------------------------------------------------------

   def load_config_development
      load_config
      ENV['DEC_VERSION']                  = DEC.class_variable_get(:@@version)
      ENV['DEC_CONFIG']                   = File.join(File.dirname(File.expand_path(__FILE__)), "../../config")
      ENV['HOSTNAME']                     = `hostname`
      ENV.delete('DCC_CONFIG')
      ENV.delete('DCC_TMP')
   end

   ## -----------------------------------------------------------------

   ## extract DEC configuration from installation directory
   def copy_installed_config(destination, nodename = "")

      checkDirectory(destination)
      ## -----------------------------
      ## DEC Config files

      arrConfigFiles = [\
         "dec_interfaces.xml",\
         "dec_incoming_files.xml",\
         "dec_outgoing_files.xml",\
         "ft_mail_config.xml",\
         "dec_log_config.xml",\
         "dec_config.xml"]
      ## -----------------------------

      path = File.join(File.dirname(File.expand_path(__FILE__)), "../../config")

      arrConfigFiles.each{|config|

         if File.exist?("#{destination}/#{config}") == true then
            puts "File #{destination}/#{config} exists already / please backup first #{'1F47A'.hex.chr('UTF-8')}"
            next
         end

         if File.exist?("#{path}/#{config}") == true then
            FileUtils.cp("#{path}/#{config}", "#{destination}/#{nodename}##{config}")
            FileUtils.ln_s("#{destination}/#{nodename}##{config}","#{destination}/#{config}")
         end
      }

   end

   ## -----------------------------------------------------------------

   def load_config

      # --------------------------------
      if !ENV['DEC_CONFIG'] then
         ENV['DEC_CONFIG'] = File.join(File.dirname(File.expand_path(__FILE__)), "../../config")
      end
      # --------------------------------

      # --------------------------------
      if !ENV['HOSTNAME'] then
         ENV['HOSTNAME'] = `hostname`
      end
      # --------------------------------

      decConfig   = DEC::ReadConfigDEC.instance
      inventory   = decConfig.getInventory

      if !ENV['DEC_DB_ADAPTER'] then
         ENV['DEC_DB_ADAPTER'] = inventory[:db_adapter]
      end

      if !ENV['DEC_DATABASE_HOST'] then
         ENV['DEC_DATABASE_HOST'] = inventory[:db_host]
      end

      if !ENV['DEC_DATABASE_PORT'] then
         ENV['DEC_DATABASE_PORT'] = inventory[:db_port]
      end

      if !ENV['DEC_DATABASE_NAME'] then
         ENV['DEC_DATABASE_NAME'] = inventory[:db_name]
      end

      if !ENV['DEC_DATABASE_USER'] then
         ENV['DEC_DATABASE_USER'] = inventory[:db_username]
      end

      if !ENV['DEC_DATABASE_PASSWORD'] then
         ENV['DEC_DATABASE_PASSWORD'] = inventory[:db_password]
      end

      if !ENV['DEC_TMP'] then
         ENV['DEC_TMP'] = decConfig.getTempDir
      end

   end

   ## -----------------------------------------------------------------

   def load_logger(label)
       # initialize logger
      loggerFactory = CUC::Log4rLoggerFactory.new(label, "#{ENV['DEC_CONFIG']}/dec_log_config.xml")

      @logger = loggerFactory.getLogger

      if @logger == nil then
		   puts "Could not set up logging system !  :-("
         puts "Check DEC logs configuration under \"#{ENV['DEC_CONFIG']}/dec_log_config.xml\""
		   puts
		   puts
		   exit(99)
      end

      return @logger
   end
   ## -----------------------------------------------------------------

   def load_config_developmentRPF
      ENV['RPF_ARCHIVE_ROOT']             = "#{ENV['HOME']}/Sandbox/dec/rpf_archive_root"
      ENV['FTPROOT']                      = "#{ENV['HOME']}/Sandbox/dec/delivery_root"
      ENV['RPFBIN']                       = File.dirname(File.expand_path(__FILE__))
   end

   ## -----------------------------------------------------------------

   ## DEC variables for communication amongst process must never be deleted

   def unset_config
      ENV.delete('DEC_VERSION')
      ENV.delete('DEC_DB_ADAPTER')
      ENV.delete('DEC_DATABASE_HOST')
      ENV.delete('DEC_DATABASE_PORT')
      ENV.delete('DEC_DATABASE_NAME')
      ENV.delete('DEC_DATABASE_USER')
      ENV.delete('DEC_DATABASE_PASSWORD')
      ENV.delete('DEC_TMP')
      ENV.delete('DEC_DELIVERY_ROOT')
   end

   ## -----------------------------------------------------------------

   def print_environment
      puts "HOME                          => #{ENV['HOME']}"
      puts "DEC_CONFIG                    => #{ENV['DEC_CONFIG']}"
      puts "DEC_DB_ADAPTER                => #{ENV['DEC_DB_ADAPTER']}"
      puts "DEC_TMP                       => #{ENV['DEC_TMP']}"
      puts "DEC_DATABASE_HOST             => #{ENV['DEC_DATABASE_HOST']}"
      puts "DEC_DATABASE_PORT             => #{ENV['DEC_DATABASE_PORT']}"
      puts "DEC_DATABASE_NAME             => #{ENV['DEC_DATABASE_NAME']}"
      puts "DEC_DATABASE_USER             => #{ENV['DEC_DATABASE_USER']}"
      puts "DEC_DATABASE_PASSWORD         => #{ENV['DEC_DATABASE_PASSWORD']}"
      puts "DEC_DEBUG_MODE                => #{ENV['DEC_DEBUG_MODE']}"
      puts "HOSTNAME                      => #{ENV['HOSTNAME']}"
   end
   ## -----------------------------------------------------------------

   def print_environmentRPF
      puts "RPFBIN                        => #{ENV['RPFBIN']}"
      puts "RPF_ARCHIVE_ROOT              => #{ENV['RPF_ARCHIVE_ROOT']}"
      puts "FTPROOT                       => #{ENV['FTPROOT']}"
   end
   ## -----------------------------------------------------------------

   def check_environment_dirs
      checkDirectory(ENV['DEC_TMP'])
   end

   ## -----------------------------------------------------------------

   def check_environment_dirs_push
      checkDirectory(DEC::ReadConfigDEC.instance.getSourceDir)
   end

   ## -----------------------------------------------------------------

   def check_environment
      retVal = checkEnvironmentEssential
      if retVal == true then
         check_environment_dirs
         return true
         # return checkToolDependencies
      else
         return false
      end
   end
   ## -----------------------------------------------------------------

   def checkEnvironmentEssential

      load_config

      bCheck = true

      # --------------------------------
      # DEC_CONFIG can be defined by the customer to override
      # the configuration shipped with the gem
      if !ENV['DEC_CONFIG'] then
         ENV['DEC_CONFIG'] = File.join(File.dirname(File.expand_path(__FILE__)), "../../config")
      end
      # --------------------------------

      if !ENV['DEC_TMP'] then
         bCheck = false
         puts "DEC_TMP environment variable is not defined !\n"
         puts
      else
         checkDirectory(ENV['DEC_TMP'])
      end

      if bCheck == false then
         puts "DEC Essential environment variables configuration not complete"
         puts
         return false
      end
      return true
   end
   ## -----------------------------------------------------------------

   def checkEnvironmentPUSH
      bCheck = true

      if bCheck == false then
         puts "DEC PUSH environment variables configuration not complete"
         puts
         return false
      end
      return true
   end
   ## -----------------------------------------------------------------

   def checkEnvironmentMail
      bCheck = true

      if !ENV['HOSTNAME'] then
         bCheck = false
         puts
         puts "HOSTNAME environment variable is not defined !\n"
         puts
      end

      if bCheck == false then
         puts "DEC environment variables configuration not complete"
         puts
         return false
      end
      return true
   end
   ## -----------------------------------------------------------------

   def checkEnvironmentDB
      bCheck = true
      if !ENV['DEC_DB_ADAPTER'] then
         bCheck = false
         puts
         puts "DEC_DB_ADAPTER environment variable is not defined !\n"
         puts
      end

      if !ENV['DEC_DATABASE_NAME'] then
         bCheck = false
         puts
         puts "DEC_DATABASE_NAME environment variable is not defined !\n"
         puts
      end

      if !ENV['DEC_DATABASE_USER'] then
         bCheck = false
         puts
         puts "DEC_DATABASE_USER environment variable is not defined !\n"
         puts
      end

      if !ENV['DEC_DATABASE_PASSWORD'] then
         bCheck = false
         puts
         puts "DEC_DATABASE_PASSWORD environment variable is not defined !\n"
         puts
      end

      if bCheck == false then
         puts "DEC database environment variables configuration not complete"
         puts
         return false
      end
      return true
   end
   ## -----------------------------------------------------------------

   def checkEnvironmentRPF
      bCheck = true
      if !ENV['RPFBIN'] then
         bCheck = false
         puts
         puts "RPFBIN environment variable is not defined !\n"
         puts
      end

      if !ENV['RPF_ARCHIVE_ROOT'] then
         bCheck = false
         puts
         puts "RPF_ARCHIVE_ROOT environment variable is not defined !\n"
         puts
      end

      if !ENV['FTPROOT'] then
         bCheck = false
         puts
         puts "FTPROOT environment variable is not defined !\n"
         puts
      end

      if bCheck == false then
         puts "DEC RPF environment variables configuration not complete"
         puts
         return false
      end
      return true

   end
   ## -----------------------------------------------------------------

   def printEnvironmentError
      puts "Execution environment not suited for DEC"
   end
   ## -----------------------------------------------------------------

   def createEnvironmentDirs
      checkDirectory(ENV['DEC_TMP'])

      if ENV['DEC_DATABASE_NAME'][0,1] == '/' then
         checkDirectory(File.dirname(ENV['DEC_DATABASE_NAME']))
      end

      # cf. $DEC_CONFIG/dec_log_config.xml
      checkDirectory("/tmp/dec/log")

   end
   ## -----------------------------------------------------------------

   def createEnvironmentDirsRPF
      checkDirectory(ENV['RPF_ARCHIVE_ROOT'])
      checkDirectory(ENV['FTPROOT'])
   end
   ## -----------------------------------------------------------------

   def checkConfigFilesIncoming
      arrFiles = [ \
                  "dec_interfaces.xml", \
                  "dec_incoming_files.xml"
                  ]
      bRet = true
      arrFiles.each{|file|
         if File.exist?("#{ENV['DEC_CONFIG']}/#{file}") == false then
            bRet = false
            puts "#{ENV['DEC_CONFIG']}/#{file} not found !"
         end
      }
      return bRet
   end

   ## -----------------------------------------------------------------

   def checkConfigFilesOutgoing
      arrFiles = [ \
                  "dec_interfaces.xml", \
                  "dec_outgoing_files.xml"
                  ]
      bRet = true
      arrFiles.each{|file|
         if File.exist?("#{ENV['DEC_CONFIG']}/#{file}") == false then
            bRet = false
            puts "#{ENV['DEC_CONFIG']}/#{file} not found !"
         end
      }
      return bRet
   end

   ## -----------------------------------------------------------------
   ##
   ## check command line tool dependencies
   ##
   def checkToolDependencies(logger = nil)

      bDefined = true
      bCheckOK = true

      arrTools = [ \
                  "7za", \
                  "jq", \
                  "xmllint", \
      #            "sqlite3", \
                  "curl", \
                  "ncftpget", \
                  "ncftpput", \
                  "openssl", \
                  "sshpass", \
                  "sftp" \
                  ]

      arrTools.each{|tool|
         isToolPresent = `which #{tool}`

         if isToolPresent[0,1] != '/' then
            if logger != nil then
               logger.error("[DEC_799] Fatal Error:  #{tool} not present in $PATH")
            else
               puts "Fatal Error: #{tool} not present in PATH   :-(\n"
            end
            bCheckOK = false
         end

      }

#      if bCheckOK == false then
#         puts "\nDEC_Environment::checkToolDependencies FAILED !\n\n"
#      end

      return bCheckOK
   end
   ## -----------------------------------------------------------------

   def checkToolDependenciesRPF
      bCheckOK = true

      arrTools = [ \
                  "removeSchema.bin", \
                  "write2Log.bin", \
                  "put_report.bin" \
                  ]

      rootDir = ENV['RPFBIN']

      arrTools.each{|tool|

         if File.exist?("#{rootDir}/#{tool}") == false then
            puts "\n\nDEC_Environment::checkToolDependenciesRPF\n"
            puts "Fatal Error: #{tool} not present in RPFBIN #{rootDir}   :-(\n\n\n"
            bCheckOK = false
         end

      }

      #check the commands needed

      if bCheckOK == false then
         puts "\nnDEC_Environment::checkToolDependencies for RPF FAILED !\n\n"
      end

      return bCheckOK
   end
   ## -----------------------------------------------------------------

end # module

## ==============================================================================

## Wrapper to make use within unit tests since it is not possible inherit mixins

class DEC_Environment

   include DEC

   def wrapper_load_config
      load_config
   end

   def wrapper_load_config_development
      load_config_development
   end

   def wrapper_load_config_developmentRPF
      load_config_developmentRPF
   end

   def wrapper_checkEnvironmentEssential
      return checkEnvironmentEssential
   end

   def wrapper_check_environment
      return check_environment
   end

   def wrapper_unset_config
      unset_config
   end

   def wrapper_check_config_files_incoming
      return checkConfigFilesIncoming
   end

   def wrapper_check_config_files_outgoing
      return checkConfigFilesOutgoing
   end

   def wrapper_print_environment
      print_environment
   end

   def wrapper_print_environmentRPF
      print_environmentRPF
   end

end

## ==============================================================================
