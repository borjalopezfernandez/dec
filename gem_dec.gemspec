require_relative 'code/dec/DEC_Environment'
include DEC

Gem::Specification.new do |s|
  s.name        = 'dec'
  s.version     = "#{DEC.class_variable_get(:@@version)}"
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.summary     = "DEC"
  s.description = "Data Exchange Component"
  s.authors     = ["cf. AUTHORS"]
  s.email       = 'mansobeach@gmail.com'

  s.files       = Dir['code/dec/*.rb'] + \
                  Dir['code/dcc/*.rb'] + \
                  Dir['code/ddc/*.rb'] + \
                  Dir['code/cuc/*.rb'] + \
                  Dir['code/dbm/*.rb'] + \
                  Dir['code/ctc/*.rb'] + \
                  Dir['schemas/*.xsd'] + \
                  Dir['man/dec.1'] + \
                  Dir['man/dec.1.html'] + \
                  Dir['man/decODataClient.1'] + \
                  Dir['man/decODataClient.1.html'] + \
                  Dir['config/dec_interfaces.xml'] + \
                  Dir['config/dec_incoming_files.xml'] + \
                  Dir['config/dec_outgoing_files.xml'] + \
                  Dir['config/ft_mail_config.xml'] + \
                  Dir['config/dec_log_config.xml'] + \
                  Dir['config/dec_config.xml']

#    ## --------------------------------------------
#    ##
#    ## Tailored installer to avoid shipping un-necessary only the OData client
#    if ENV.include?("DEC_ODATA") == false then
#       s.files = s.files + Dir['config/dec_incoming_files.xml']
#       s.files = s.files + Dir['config/dec_outgoing_files.xml']
#       s.files = s.files + Dir['config/dec_interfaces.xml']
#       s.files = s.files + Dir['config/ft_mail_config.xml']
#    end
#    ## --------------------------------------------

  s.require_paths = [ 'code', 'code/ctc', 'code/dec' ]

  s.bindir        = [ 'code/dec' ]

  s.executables   = [
                     'decNATS', \
                     'decValidateConfig', \
                     'decCheckConfig', \
                     'decListDirUpload', \
                     'decConfigInterface2DB', \
                     'decDeliverFiles', \
                     'decGetFiles4Transfer', \
                     'decGetFromInterface', \
                     'decListener', \
                     'decManageDB', \
                     'decNotify2Interface', \
                     'decODataClient', \
                     'decSend2Interface', \
                     'decSmokeTests', \
                     'decStats'\
                     ]

   if ENV.include?("DEC_NAOS") == true then
      s.executables   << 'dec_script_NAOS_NASA_RFM'
   end

   if ENV.include?("DEC_ADGS") == true then
      s.executables   << 'dec_script_ADGS_S1MPC'
   end

   ## --------------------------------------------
   ##
   ## Tailored installer to include only the OData client
   if ENV.include?("DEC_ODATA") == true then
      s.executables   << 'decODataClient'
   end
   ## --------------------------------------------

   ## --------------------------------------------
   ##
   ## Tailored installer to include only the OData client
   if ENV.include?("DEC_TEST") == true then

      puts
      puts "Adding unit tests"
      puts

      s.executables   << 'decTestInterface_CelesTrak'
      s.executables   << 'decTestInterface_CloudFerro'
      s.executables   << 'decTestInterface_ECDC'
      s.executables   << 'decTestInterface_IERS'
      s.executables   << 'decTestInterface_ILRS'
      s.executables   << 'decTestInterface_GNSS'
      s.executables   << 'decTestInterface_NASA'
      s.executables   << 'decTestInterface_NATS_CCS5'
      s.executables   << 'decTestInterface_NOAA'
      s.executables   << 'decTestInterface_SCIHUB'
      s.executables   << 'decTestInterface_SPCS'
      s.executables   << 'decUnitTests'
      s.executables   << 'decUnitTests_ADP'
      s.executables   << 'decUnitTests_ADGS'
      s.executables   << 'decUnitTests_FTP'
      s.executables   << 'decUnitTests_FTP_PASSIVE'
      s.executables   << 'decUnitTests_FTPS'
      s.executables   << 'decUnitTests_FTPS_IMPLICIT'
      s.executables   << 'decUnitTests_HTTP'
      s.executables   << 'decUnitTests_LOCAL'
      s.executables   << 'decUnitTests_ncftpput'
      s.executables   << 'decUnitTests_SBOA'
      s.executables   << 'decUnitTests_SFTP'
      s.executables   << 'decUnitTests_SFTP_PASSWORD'
      s.executables   << 'decUnitTests_WebDAV'
      s.executables   << 'decUnitTests_WebDAV_SECURE'
      s.executables   << 'decUnitTests_mail'

      if ENV.include?("DEC_ODATA") == true then
         s.executables   << 'decTestInterface_OData_ADGS'
         s.executables   << 'decTestInterface_OData_DHUS'
         s.executables   << 'decTestInterface_S2PRIP'
      end

      if ENV.include?("DEC_NAOS") == true then
         s.executables   << 'decTestInterface_NAOS_IVV-0500'
      end

   end
   ## --------------------------------------------


  s.homepage    = 'https://github.com/borjalopezfernandez/dec'
  s.metadata    = { "source_code_uri" => "https://github.com/borjalopezfernandez/dec" }

  ## ----------------------------------------------

  s.required_ruby_version = '> 3.0'

  ## ----------------------------------------------

  s.add_dependency('activerecord', '~> 6.0')
  s.add_dependency('bcrypt', '~> 3.1')
  s.add_dependency('bcrypt_pbkdf', '~> 1.1')
  s.add_dependency('curb', '~> 0.9')
  s.add_dependency('dotenv', '~> 2')
  s.add_dependency('ffi', '~> 1.15')
  s.add_dependency('filesize', '~> 0.1')
  s.add_dependency('ftools', '~> 0.0')
  s.add_dependency('ftpfxp', '~> 0.0')
  s.add_dependency('log4r', '~> 1.0')
  s.add_dependency('manpages', '~> 0.6')
  s.add_dependency('nats', '~> 0.11')
  s.add_dependency('nats-pure', '~> 2.0')
  s.add_dependency('net_dav', '~> 0.5')
  s.add_dependency('net-ftp', '~> 0.1')
  s.add_dependency('net-pop', '~> 0.1')
  s.add_dependency('net-sftp', '~> 4.0')
  s.add_dependency('net-smtp', '~> 0.3')
  s.add_dependency('net-ssh', '~> 7.2')
  s.add_dependency('rexml', '~> 3.2')
  s.add_dependency('roman-numerals', '~> 0.3')
  s.add_dependency('ed25519', '~> 1.3')
  s.add_dependency('nokogiri', '~> 1.1')
  s.add_dependency('shell', '~> 0.8')

  if ENV.include?("DEC_TEST") == true then
     s.add_dependency('minitest', '~> 5.15')
     s.add_dependency('test-unit', '~> 3.5')
  end

#  ## --------------------------------------------
#  ##
#  ## Tailored installer to avoid some gems only for the OData client
#  if ENV.include?("DEC_ODATA") == false then
#     s.add_dependency('curb', '~> 0.9')
#  end
#  ## --------------------------------------------

  ## --------------------------------------------
  ##
  ## Tailored installer to include Postgresql
  if ENV.include?("DEC_PG") == true then
     s.add_dependency('pg', '~> 1.2.3')
  end
  ## --------------------------------------------

  s.add_dependency('sqlite3', '~> 1.4')
  s.add_dependency('sys-filesystem', '~> 1.3')

  ## ----------------------------------------------

  s.add_development_dependency('coderay', '~> 1.1')
  s.add_development_dependency('rspec', '~> 3.9')
  s.add_development_dependency('sqlite3', '~> 1.4')
  s.add_development_dependency('test-unit', '~> 3.0')


  ## ----------------------------------------------

  s.post_install_message = "#{'1F4E1'.hex.chr('UTF-8')} DEC #{'1F47E'.hex.chr('UTF-8')} Data Exchange Component installed #{DEC.class_variable_get(:@@version)} \360\237\215\200 \360\237\215\200 \360\237\215\200"

  ## ----------------------------------------------

end

### ============================================================================
