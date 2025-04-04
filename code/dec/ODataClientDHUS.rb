#!/usr/bin/env ruby

require 'rubygems'

require 'ctc/API_DHUS'

require 'dec/ODataClientBase'

module DEC

class ODataClientDHUS < ODataClientBase
   
   ## -------------------------------------------------------------
   
   def initialize(user, password, query, creationtime, datetime, sensingtime, full_path_dir, download, logger)
      
      super(user, password, query, creationtime, datetime, sensingtime, full_path_dir, download, logger)
      
      if @mission == "GNSS" then
         @urlCount    = DHUS::API_URL_ODATA_PRODUCT_COUNT_GNSS
         @urlSelect   = DHUS::API_URL_ODATA_PRODUCT_SELECT_ID_GNSS
         @urlPaging   = DHUS::API_URL_ODATA_PRODUCT_PAGING_GNSS
      else
         @urlCount    = DHUS::API_URL_ODATA_PRODUCT_COUNT
         @urlSelect   = DHUS::API_URL_ODATA_PRODUCT_SELECT_ID_S1
         @urlPaging   = DHUS::API_URL_ODATA_PRODUCT_PAGING_S1
      end

      if @sensingtime != nil then
         @urlSelect   = DHUS::API_URL_ODATA_PRODUCT_SELECT_BY_SENSING
         @urlPaging   = DHUS::API_URL_ODATA_PRODUCT_PAGING_BY_SENSING
      
         if @format == "json" then
            @urlSelect   = DHUS::API_URL_ODATA_PRODUCT_SELECT_BY_SENSING_JSON
            @urlPaging   = DHUS::API_URL_ODATA_PRODUCT_PAGING_BY_SENSING_JSON 
         end

         if @format == "csv" then
            @urlSelect   = DHUS::API_URL_ODATA_PRODUCT_SELECT_BY_SENSING_CSV
            @urlPaging   = DHUS::API_URL_ODATA_PRODUCT_PAGING_BY_SENSING_CSV
         end
      end
      
      if @datetime != nil or @creationtime != nil then
         if @format == "json" then
            urlSelect   = DHUS::API_URL_ODATA_PRODUCT_SELECT_ID_S1_JSON
            urlPaging   = DHUS::API_URL_ODATA_PRODUCT_PAGING_S1_JSON   
         end

         if @format == "csv" then
            @urlSelect   = DHUS::API_URL_ODATA_PRODUCT_SELECT_ID_S1_CSV
            @urlPaging   = DHUS::API_URL_ODATA_PRODUCT_PAGING_S1_CSV  
         end
      end

      @condition   = "#{DHUS::API_ODATA_FILTER_SUBSTRINGOF}(%27#{@datatake}%27,Name)"

      if @param != nil then
         @condition   = "#{@condition.dup} and substringof(%27#{@param}%27,Name)"
         @urlCount    = "#{@urlCount.dup}#{@condition}"
      end   
      
      @serviceRootUri         = DHUS::API_ROOT
      @attributeDateAvailable = DHUS::API_ODATA_ATTRIBUTE_DATE_AVAILABILITY
      @bUseDateTime           = true 
   end
   ## -----------------------------------------------------------
  
   ## Set the flag for debugging on.
   def setDebugMode
      @isDebugMode = true
      @logger.debug("ODataClientDHUS debug mode is on")
   end
   ## -----------------------------------------------------------

end # class

end # module


