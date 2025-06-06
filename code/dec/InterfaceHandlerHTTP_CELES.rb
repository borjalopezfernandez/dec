#!/usr/bin/env ruby

### https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html

### HTTP verbs used:
### > HEAD: same as GET but does not return the message body (to list files prior pull operations)

require 'ctc/WrapperCURL'
require 'dec/ReadInterfaceConfig'
require 'dec/ReadConfigOutgoing'
require 'dec/ReadConfigIncoming'
require 'dec/InterfaceHandlerAbstract'

require 'uri'
require 'net/http'
require 'curb'
require 'nokogiri'
require 'fileutils'

module DEC


class InterfaceHandlerHTTP_CELES < InterfaceHandlerAbstract

   include CTC::WrapperCURL

   ## -----------------------------------------------------------
   ##
   ## Class constructor.
   ## * entity (IN):  Entity textual name (i.e. FOS)
   def initialize(entity, log, pull=true, push=true, manageDirs=false, isDebug=false)
      @entity     =  entity
      @logger     =  log
      @manageDirs =  manageDirs
      
      if isDebug == true then
         self.setDebugMode
      else
         @isDebugMode = false
      end

      @entityConfig     = ReadInterfaceConfig.instance
      @outConfig        = ReadConfigOutgoing.instance
      @inConfig         = ReadConfigIncoming.instance
      @isSecure         = @entityConfig.isSecure?(@entity)
      @server           = @entityConfig.getServer(@entity)
      @verifyPeerSSL    = @entityConfig.isVerifyPeerSSL?(@entity)
      @uploadDir        = @outConfig.getUploadDir(@entity)
      @arrPullDirs      = @inConfig.getDownloadDirs(@entity)    
      @http             = nil
      @url              = nil   
   end   
   ## -----------------------------------------------------------
   ##
   ## Set the flag for debugging on
   def setDebugMode
      @isDebugMode = true
      @logger.debug("InterfaceHandlerHTTP debug mode is on") 
   end
   ## -----------------------------------------------------------

   def pushFile(file)
      url = ""
      
      if @uploadDir[0,1] == '/' then
         url = "#{@server[:hostname]}:#{@server[:port]}#{@uploadDir}"
      else
         url = "#{@server[:hostname]}:#{@server[:port]}/#{@uploadDir}"
      end
      
      if @server[:isSecure] == false then
         url = "http://#{url}"
      else
         url = "https://#{url}/"
      end
      
      if @isDebugMode == true then
         @logger.debug("InterfaceHandlerHTTP::pushFile => #{file} / #{@url} by @server[:user]")
      end
      return putFile(url, @verifyPeerSSL, @server[:user], @server[:password], file, @isDebugMode, @logger)
   end
   ## -----------------------------------------------------------

   ## -----------------------------------------------------------

   def checkConfig(entity, pull, push)
      checker     = CheckerInterfaceConfig.new(entity, pull, push, @logger, @isDebugMode)
      
      if @isDebugMode == true then
         checker.setDebugMode
      end
      
      retVal      = checker.check
 
      if retVal == true then
         if @isDebugMode == true then
            @logger.debug("#{entity} I/F is configured correctly")
 	      end
      else
         raise "[DEC_000] I/F #{entity}: init / configuration problem"
      end
   end

   ## -----------------------------------------------------------

   ## -----------------------------------------------------------
   ## DEC - Pull


   ## -----------------------------------------------------------

   ## -----------------------------------------------------------
   ## -----------------------------------------------------------

   def getUploadDirList(bTemp = false)
      if @isDebugMode == true then
         @logger.debug("InterfaceHandlerHTTP::getUploadDirList tmp => #{bTemp}")
      end
      
      dir      = nil
      
      if bTemp == false then
         dir = @outConfig.getUploadDir(@entity)
      else
         dir = @outConfig.getUploadTemp(@entity)
      end
      
      if @isDebugMode == true then
         @logger.debug("InterfaceHandlerHTTP::getUploadDirList tmp => #{bTemp} / #{dir}")
      end
   
      return self.getDirList(dir)
   
   end
   ## -----------------------------------------------------------
   
   def getPullList(bShortCircuit = false)
      newArrFile = Array.new      
      @arrPullDirs.each{|element|
         dir         = element[:directory]
         
         # ---------------------------------------
         # URL ends with "/" treat it as a directory         
         if dir[-1, 1] == "/" then
            newArrFile << getDirList(dir, bShortCircuit)
            next
         else
            newArrFile << getListFile(dir, bShortCircuit)
            next         
         end 
         # ---------------------------------------
      }
      return newArrFile.flatten
   end
   ## -----------------------------------------------------------
   
   ## Need to make it pure HTTP
   
   def getDirList(remotePath, shortCircuit = false)
      if @isDebugMode == true then
         @logger.debug("InterfaceHandlerHTTP::getDirList => #{remotePath} url treated as a directory")
      end

      host        = ""
      url         = ""
      port        = @server[:port].to_i
      user        = @server[:user]
      pass        = @server[:password]
   
      if @isSecure == false then
         host        = "http://#{@server[:hostname]}:#{@server[:port]}/"
      else
         host        = "https://#{@server[:hostname]}/"
      end

      url = "#{host}#{remotePath}"
      uri = URI.parse(url)
      
      ## ------------------
      ## Request headers
      response = nil
      response = Net::HTTP.get_response(uri)
      
      if @isDebugMode == true then
         @logger.debug("HTTP HEAD #{url} => #{response.code}")
      end
         
      if @isDebugMode == true and response.code.to_i == 200 then 
         puts response.body
      end
      
              
      if response.code.to_i == 404 or response.code.to_i == 400 then
         if shortCircuit == true then 
            raise "I/F #{@entity}: #{response.code} / #{url}"
         else
            @logger.error("I/F #{@entity}: #{response.code} / #{url}")
         end
      end
      ## ------------------
      
      ## https://stackoverflow.com/questions/39653384/how-to-extract-html-links-and-text-using-nokogiri-and-xpath-and-css
      
      arr = Array.new

      doc   = Nokogiri::HTML.parse(response.body)
      
      # Get all anchors via xpath
      
      # tags  = doc.xpath("//a")
      
      tags  = doc.xpath('//a/@href')
      
      tags.each do |tag|
         if @isDebugMode == true then
            @logger.debug(tag)
         end
         arr << "#{url}#{tag.text}"
      end
   
      return arr
   end
	## -----------------------------------------------------------

   def getListFile(remotePath, shortCircuit = false)
      if @isDebugMode == true then
         @logger.debug("InterfaceHandlerHTTP::getListFile => #{remotePath} url treated as a file")
      end

      require 'net/https'
      require 'uri'


      host        = ""
      url         = ""
      port        = @server[:port].to_i
      user        = @server[:user]
      pass        = @server[:password]
   
      if @isSecure == false then
         host        = "http://#{@server[:hostname]}:#{@server[:port]}/"
      else
         host        = "https://#{@server[:hostname]}/"
      end

      url = "#{host}#{remotePath}"

      if @isDebugMode == true then
         @logger.debug(url)
      end


      begin

         bFound   = false
         req      = Curl::Easy.new(url)
         
         if user != nil and user != "" then
            req.username = user
         end

         if pass != nil and pass != "" then
            req.password = pass
         end

         req.http_head
         ret = req.perform

         if ret == true then
            if @isDebugMode == true then
               @logger.debug("Found #{File.basename(url)}")
            end
            return url
         end
         
         if @isDebugMode == true then
            @logger.debug("#{url} => #{ret.status}")
         end
                        
         ## -----------------------------------
         ## Permanent re-direction
         if ret.status.include?("301") == true then               
            new_url = ret.header_str.split("location:")[1].split("\n")[0].gsub(/\s+/, "")
            url = new_url
            bFound = true
            if @isDebugMode == true then
               @logger.debug("Found #{File.basename(new_url)}")
            end
         end
            
         ## -----------------------------------
                        
         if ret.status.include?("200") == true then
            bFound = true
            
            if @isDebugMode == true then
               @logger.debug("Found #{File.basename(url)}")
            end
         end

         if bFound == false then
            @logger.error("[DEC_614] I/F #{@entity}: Cannot HEAD #{url}")
         end
      rescue Exception => e
         @logger.error("[DEC_614] I/F #{@entity}: Cannot HEAD #{url}")
         @logger.error(e.to_s)
         if @isDebugMode == true then
            @logger.debug(e.backtrace)
         end
      end
         
      ## -----------------------------------
      
      return url  
   
   end
	## -------------------------------------------------------------
   
   ## -------------------------------------------------------------
   ##
   ## download file using HTTP protocol verb GET 
   ##
   def downloadFile(url)
      filename = File.basename(url)

      if filename.include?("?") == true then
         return httpGetAPI(url)
      end

      if @isDebugMode == true then
         @logger.debug("InterfaceHandlerHTTP::downloadFile => #{url} url treated as a file / #{filename}")
      end
      
      http = Curl::Easy.new(url)
      
      # HTTP "insecure" SSL connections (like curl -k, --insecure) to avoid Curl::Err::SSLCACertificateError
      
      http.ssl_verify_peer = @verifyPeerSSL
      
      # Curl::Err::SSLPeerCertificateError ?????
      http.ssl_verify_host = false      
      http.http_auth_types = :basic

      user        = @server[:user]
      pass        = @server[:password]

      if user != "" and user != nil then
         http.username = user
      end
      
      if pass != "" and pass != nil then
         http.password = pass
      end

      ret = http.perform

      if http.response_code == 302 then
         return getFileWithRedirection(url, filename, user, pass, @logger, @isDebugMode)
      else
         puts ret
         puts http.body_str
         puts http.response_code
         return ret
      end
      
  
      return true



      ## https://github.com/taf2/curb

      ## REDIRECT
      ## https://ruby-doc.org/stdlib-2.4.2/libdoc/net/http/rdoc/Net/HTTP.html


#      uri = URI.parse(url)
#      http = Net::HTTP.get_response(uri)

      ## TO DO : replace in memory file with 
      ## https://www.rubydoc.info/github/taf2/curb/Curl/Easy#download-class_method

      # @logger.debug(http.code)

      # puts url
      # filename = getFilenameFromFullPath(url)
      
      
      
      aFile = File.new(filename, "wb")
      # aFile.write(http.body)
      aFile.write(http.body_str)
      aFile.flush
      aFile.close
 
      size = File.size("#{File.basename(filename)}")
         
      @logger.info("[DEC_110] I/F #{@entity}: #{File.basename(filename)} downloaded with size #{size} bytes")
		
      # File is made available at the interface inbox	
      copyFileToInBox(File.basename(filename), size)
			         
		# Update DEC Inventory
	   setReceivedFromEntity(File.basename(filename), size)
	
      # if deleteFlag is enable delete it from remote directory
      ret = deleteFromEntity(url)

      return true
      
      
   end
      
   ## -------------------------------------------------------------


private

   ## -------------------------------------------------------------
   ##
   ## -------------------------------------------------------------
   def httpGetAPI(url)
      return true
   end


end # class

end # module
