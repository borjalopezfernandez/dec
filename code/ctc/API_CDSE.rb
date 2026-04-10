#!/usr/bin/env ruby

## https://scihub.copernicus.eu/userguide/ODataAPI
## > https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$select=Name,CreationDate,IngestionDate,Online,ContentDate
##
## OData https://scihub.copernicus.eu/apihub/odata/v1

## https://documentation.dataspace.copernicus.eu/APIs/OData.html#top-option

=begin
By default, if the orderby option is not used, the results are not ordered. If orderby option is used, additional orderby by id is also used, so that the results are fully ordered, and no products are lost while paginating through the results.

The acceptable arguments for this option: ContentDate/Start, ContentDate/End, PublicationDate, ModificationDate, in directions: asc, desc.

=end


## URL Percent Encoding
## https://en.wikipedia.org/wiki/Percent-encoding
### %27 => '
### %24 => $ This one must be escaped with curl

module CDSE

   API_ROOT = "https://catalogue.dataspace.copernicus.eu"

   API_URL_ODATA_PRODUCT_PAGING     =\
    "#{API_ROOT}/odata/v1/Products?$format=xml&$select=Id,Online,ContentLength,CreationDate,IngestionDate,EvictionDate,ContentDate,ContentGeometry&$top=50&$skip="

=begin
   API_URL_ODATA_PRODUCT_SELECT_ID  =\
    "#{API_ROOT}/odata/v1/Products?$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')&$expand=Assets"
=end

   API_URL_ODATA_PRODUCT_SELECT_ID  =\
    "#{API_ROOT}/odata/v1/Products?$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')&$expand=Attributes" 

   API_URL_ODATA_COUNT_SENTINEL3_OL_1_ERR___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$top=1&$count=True&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')"

   API_URL_ODATA_COUNT_SENTINEL3_OL_1_EFR___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$top=1&$count=True&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')" 


   API_URL_ODATA_SELECT_BASE_SENTINEL3_OL_1_ERR___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')"

   API_URL_ODATA_SELECT_BASE_SENTINEL3_OL_1_EFR___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')"

   API_URL_ODATA_SELECT_SENTINEL3_OL_1_ERR___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')&$orderby=ContentDate/Start asc&$top=1000"

   API_URL_ODATA_SELECT_SENTINEL3_OL_1_EFR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')&$orderby=ContentDate/Start asc&$top=1000"

   API_URL_ODATA_SELECT_PAGING_BASE_SENTINEL3_OL_1_ERR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')"

   API_URL_ODATA_SELECT_PAGING_BASE_SENTINEL3_OL_1_EFR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')"


   API_URL_ODATA_SELECT_PAGING_SENTINEL3_OL_1_ERR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')&$orderby=ContentDate/Start asc&$top=1000&$skip="

   API_URL_ODATA_SELECT_PAGING_SENTINEL3_OL_1_EFR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')&$orderby=ContentDate/Start asc&$top=1000&$skip="

   API_URL_ODATA_PRODUCT_PAGING_S3     =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=CreationDate asc&$format=xml&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry&$top=50&$skip="
  
   API_URL_ODATA_PRODUCT_SELECT_ID_S3  =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=CreationDate asc&$format=xml&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry"

   API_URL_ODATA_PRODUCT_PAGING_S3_CSV    =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=CreationDate asc&$format=text/csv&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry&$top=50&$skip="
   API_URL_ODATA_PRODUCT_SELECT_ID_S3_CSV  =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=CreationDate asc&$format=text/csv&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry"
   API_URL_ODATA_PRODUCT_PAGING_S3_JSON    =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=CreationDate asc&$format=json&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry&$top=50&$skip="
   API_URL_ODATA_PRODUCT_SELECT_ID_S3_JSON  =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=CreationDate asc&$format=json&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry"

   API_URL_ODATA_PRODUCT_SELECT_BY_SENSING_NOT_SORT  =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$format=json&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry"

   API_URL_ODATA_PRODUCT_PAGING_BY_SENSING_NOT_SORT     =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$format=json&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry&$top=50&$skip="

   API_URL_ODATA_PRODUCT_SELECT_BY_SENSING =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=ContentDate/Start asc&$format=xml&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry"

   API_URL_ODATA_PRODUCT_PAGING_BY_SENSING =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=ContentDate/Start asc&$format=xml&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry&$top=50&$skip="

   API_URL_ODATA_PRODUCT_SELECT_BY_SENSING_CSV =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=ContentDate/Start asc&$format=text/csv&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry"
   API_URL_ODATA_PRODUCT_PAGING_BY_SENSING_CSV =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=ContentDate/Start asc&$format=text/csv&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry&$top=50&$skip="

   API_URL_ODATA_PRODUCT_SELECT_BY_SENSING_JSON =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=ContentDate/Start asc&$format=json&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry"
   API_URL_ODATA_PRODUCT_PAGING_BY_SENSING_JSON =\
    "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$orderby=ContentDate/Start asc&$format=json&$select=Name,Id,IngestionDate,CreationDate,Online,ContentLength,EvictionDate,ContentDate,ContentGeometry&$top=50&$skip="

   API_ODATA_ATTRIBUTE_DATE_AVAILABILITY = "CreationDate"


   # API_URL_ODATA_PRODUCT_SELECT_ID  = "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$select=*"
   # API_URL_ODATA_PRODUCT_COUNT      = "https://catalogue.dataspace.copernicus.eu/odata/v1/Products/$count?"

   # https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$filter=Collection/Name eq 'SENTINEL-1' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'IW_GRDH_1S') and ContentDate/Start gt 2022-05-03T00:00:00.000Z and ContentDate/Start lt 2022-05-03T12:00:00.000Z&$count=True

   # API_URL_ODATA_PRODUCT_COUNT      = "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR__')&$count=True"

   # API_URL_ODATA_PRODUCT_COUNT      = "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$filter=Collection/Name eq 'SENTINEL-1' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'IW_GRDH_1S')"

   API_URL_ODATA_PRODUCT_COUNT      = "https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')"


   # https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$filter=Collection/Name%20eq%20%27SENTINEL-2%27
   
   API_ODATA_FILTER_SUBSTRINGOF     = "&$filter=contains"
   
   APID_ODATA_COUNT_SUFFIX          = "&$count=True"

   API_ODATA_FILTER_ENDSWITH        = "&$filter=endswith"

   API_ODATA_ORDERBY_CONTENTDATE_START_ASC   = "&$orderby=ContentDate/Start asc"
   API_ODATA_ORDERBY_CONTENTDATE_START_DESC  = "&$orderby=ContentDate/Start desc"
   
   API_ODATA_FILTER_PUBLICATIONDATE   = " and PublicationDate gt "

   API_ODATA_ORDERBY_ASC            = "&$filter=IngestionDate gt datetime'2021-03-24T00:00:00.000'"
   
   API_ODATA_FILTER_INGESTIONDATE   = "&$filter=IngestionDate gt datetime'2021-03-24T00:00:00.000'"

   ## https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$filter=year(IngestionDate) eq 2017 and month(IngestionDate) eq 12
   
   API_ODATA_FILTER_VALIDITY        = "&$filter=ContentDate/Start ge datetime '2021-03-24T00:00:00.000 and ContentDate/End le datetime'2021-03-25T00:00:00.000'"
   
   API_RESOURCE_FOUND               = "200"
   API_TOP_LIMIT_ITEMS              = 1000
end
