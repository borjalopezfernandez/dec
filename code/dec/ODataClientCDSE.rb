#!/usr/bin/env ruby

require 'rubygems'

require 'ctc/API_CDSE'
require 'dec/ODataClientBase'

module DEC

class ODataClientCDSE < ODataClientBase
   
   ## -------------------------------------------------------------
   
   def initialize(user, password, query, creationtime, datetime, sensingtime, full_path_dir, download, logger, debug = false)
      
      super(user, password, query, creationtime, datetime, sensingtime, full_path_dir, download, logger, debug)

      # self.setDebugMode

      if @isDebugMode == true then
         @logger.debug("ODataClientCDSE initialize with query: #{query}, creationtime: #{creationtime}, datetime: #{datetime}, sensingtime: #{sensingtime}, full_path_dir: #{full_path_dir}, download: #{download}")
      end

      @topLimits   = CDSE::API_TOP_LIMIT_ITEMS

      @urlCount    = CDSE::API_URL_ODATA_PRODUCT_COUNT
      @urlSelect   = CDSE::API_URL_ODATA_PRODUCT_SELECT_ID
      @urlPaging   = CDSE::API_URL_ODATA_PRODUCT_PAGING

      if query.include?("S3") and query.include?("OL_1_ERR___") then
         @urlCount    = CDSE::API_URL_ODATA_COUNT_SENTINEL3_OL_1_ERR___
         @urlSelect   = CDSE::API_URL_ODATA_SELECT_SENTINEL3_OL_1_ERR___
         @urlPaging   = CDSE::API_URL_ODATA_SELECT_PAGING_SENTINEL3_OL_1_ERR___
      end

      if query.include?("S3") and query.include?("OL_1_EFR___") then
         @urlCount    = CDSE::API_URL_ODATA_COUNT_SENTINEL3_OL_1_EFR___
         @urlSelect   = CDSE::API_URL_ODATA_SELECT_SENTINEL3_OL_1_EFR___
         @urlPaging   = CDSE::API_URL_ODATA_SELECT_PAGING_SENTINEL3_OL_1_EFR___
      end

      if query.include?("S3") and query.include?("SL_1_RBT___") then
         @urlCount    = CDSE::API_URL_ODATA_COUNT_SENTINEL3_SL_1_RBT___
         @urlSelect   = CDSE::API_URL_ODATA_SELECT_SENTINEL3_SL_1_RBT___
         @urlPaging   = CDSE::API_URL_ODATA_SELECT_PAGING_SENTINEL3_SL_1_RBT___
      end

      if @sensingtime != nil then
         @urlSelect   = CDSE::API_URL_ODATA_PRODUCT_SELECT_BY_SENSING
         @urlPaging   = CDSE::API_URL_ODATA_PRODUCT_PAGING_BY_SENSING
      
         if @format == "json" then
            @urlSelect   = CDSE::API_URL_ODATA_PRODUCT_SELECT_BY_SENSING_JSON
            @urlPaging   = CDSE::API_URL_ODATA_PRODUCT_PAGING_BY_SENSING_JSON 
         end

         if @format == "csv" then
            @urlSelect   = CDSE::API_URL_ODATA_PRODUCT_SELECT_BY_SENSING_CSV
            @urlPaging   = CDSE::API_URL_ODATA_PRODUCT_PAGING_BY_SENSING_CSV
         end
      end
      
      if @datetime != nil and @isDebugMode == true then
         @logger.debug("ODataClientCDSE initialize with datetime: #{datetime}")
         @logger.debug("ODataClientCDSE PublicationDate urlCount: #{@urlCount}")
         @logger.debug("ODataClientCDSE PublicationDate urlSelect: #{@urlSelect}")
         @logger.debug("ODataClientCDSE PublicationDate urlPaging: #{@urlPaging}")
      end

      if @datetime != nil and query.include?("OL_1_ERR___") then
         @urlCount    = "#{@urlCount.dup}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}"
         @urlSelect   = "#{CDSE::API_URL_ODATA_SELECT_BASE_SENTINEL3_OL_1_ERR___}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}&$orderby=ContentDate/Start asc&$top=1000"
         @urlPaging   = "#{CDSE::API_URL_ODATA_SELECT_PAGING_BASE_SENTINEL3_OL_1_ERR___}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}&$orderby=ContentDate/Start asc&$top=1000&$skip="
      end

      if @datetime != nil and query.include?("OL_1_EFR___") then
         @urlCount    = "#{@urlCount.dup}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}"
         @urlSelect   = "#{CDSE::API_URL_ODATA_SELECT_BASE_SENTINEL3_OL_1_EFR___}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}&$orderby=ContentDate/Start asc&$top=1000"
         @urlPaging   = "#{CDSE::API_URL_ODATA_SELECT_PAGING_BASE_SENTINEL3_OL_1_EFR___}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}&$orderby=ContentDate/Start asc&$top=1000&$skip="
      end

      if @datetime != nil and query.include?('SL_1_RBT___') then
         @urlCount    = "#{@urlCount.dup}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}"
         @urlSelect   = "#{CDSE::API_URL_ODATA_SELECT_BASE_SENTINEL3_SL_1_RBT___}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}&$orderby=ContentDate/Start asc&$top=1000"
         @urlPaging   = "#{CDSE::API_URL_ODATA_SELECT_PAGING_BASE_SENTINEL3_SL_1_RBT___}#{CDSE::API_ODATA_FILTER_PUBLICATIONDATE}#{datetime}&$orderby=ContentDate/Start asc&$top=1000&$skip="
      end

      if @param != nil then
         @condition   = "#{@condition.dup} and substringof(%27#{@param}%27,Name)"
         @urlCount    = "#{@urlCount.dup}#{@condition}#{CDSE::APID_ODATA_COUNT_SUFFIX}"
      end
      
      @serviceRootUri         = CDSE::API_ROOT
      @attributeDateAvailable = CDSE::API_ODATA_ATTRIBUTE_DATE_AVAILABILITY
      @bUseDateTime           = true 
   end
   ## -----------------------------------------------------------
  
end # class

end # module


