#!/usr/bin/env ruby

require 'rubygems'
require 'getoptlong'
require 'net/http'
require 'date'
require 'nokogiri'
require 'json'
require 'filesize'

require 'cuc/Log4rLoggerFactory'

require 'dec/DEC_Environment'

require 'dec/ODataClientADGS'
require 'dec/ODataClientTEST_ADGS'
require 'dec/ODataClientDHUS'
require 'dec/ODataClientDHUS_S5P'


module DEC

class ODataClientFactory

   include CUC::DirUtils
   include DEC
   
   ## -------------------------------------------------------------
   
   def initialize(user, password, query, creationtime, datetime, sensingtime, full_path_dir, download, logger)
      @user          = user
      @password      = password
      @query         = query
      @creationtime  = creationtime
      @datetime      = datetime
      @sensingtime   = sensingtime
      @full_path_dir = full_path_dir
      @download      = download
      @logger        = logger
      @query         = query
      @logger        = logger            
   end
   ## -----------------------------------------------------------
  
   ## Set the flag for debugging on.
   def setDebugMode
      @isDebugMode = true
      @logger.debug("ODataClientFactory debug mode is on")
   end
   ## -----------------------------------------------------------


   ## -----------------------------------------------------------

   def get_instance
   
      if @query.include?("TEST_ADGS") == true then
         return ODataClientTEST_ADGS.new(@user, @password, @query, @creationtime, @datetime, @sensingtime,  @full_path_dir, @download, @logger)
      end
  
      if @query.include?("ADGS") == true then
         return ODataClientADGS.new(@user, @password, @query, @creationtime, @datetime, @sensingtime,  @full_path_dir, @download, @logger)
      end

      if @query.include?("DHUS_S5P") == true then
         return ODataClientDHUS_S5P.new(@user, @password, @query, @creationtime, @datetime, @sensingtime,  @full_path_dir, @download, @logger)
      end

      if @query.include?("DHUS") == true then
         return ODataClientDHUS.new(@user, @password, @query, @creationtime, @datetime, @sensingtime,  @full_path_dir, @download, @logger)
      end
      
      raise "no OData instance recognised for the query #{@query}"
            
   end

   ## -------------------------------------------------------------

end # class

end # module


