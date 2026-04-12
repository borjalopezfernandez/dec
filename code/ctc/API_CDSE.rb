#!/usr/bin/env ruby

##
## CDSE - Copernicus Data Space Ecosystem
## https://dataspace.copernicus.eu/
##
## > https://documentation.dataspace.copernicus.eu/APIs/OData.html
## > https://documentation.dataspace.copernicus.eu/APIs/OData.html#odata-products-endpoint
## > https://documentation.dataspace.copernicus.eu/APIs/OData.html#query-collection-of-products
## > https://catalogue.dataspace.copernicus.eu/odata/v1/Products?$select=Name,CreationDate,IngestionDate,Online,ContentDate
## > https://documentation.dataspace.copernicus.eu/APIs/OData.html#top-option
##
## > https://documentation.dataspace.copernicus.eu/APIs/OData.html#query-by-attributes
## Attributes/OData.CSC.ValueTypeAttribute/any(att:att/Name eq ‘[Attribute.Name]’ and att/OData.CSC.ValueTypeAttribute/Value eq [Attribute.Value])
## Attributes/OData.CSC.StringAttribute/any(att:att/Name eq ‘[Attribute.Name]’ and att/OData.CSC.StringAttribute/Value eq ‘[Attribute.Value]’)
##
##
## Authentication:
## https://documentation.dataspace.copernicus.eu/APIs/Token.html
##
## Sentinel-3 OLCI products in the CDSE catalogue
## https://catalogue.dataspace.copernicus.eu/odata/v1/Attributes(SENTINEL-3)
## [{"Name":"productType","ValueType":"String"},{"Name":"landCover","ValueType":"Double"},{"Name":"cloudCover","ValueType":"Double"},{"Name":"timeliness","ValueType":"String"},{"Name":"brightCover","ValueType":"Double"},{"Name":"coordinates","ValueType":"String"},{"Name":"cycleNumber","ValueType":"Integer"},{"Name":"orbitNumber","ValueType":"Integer"},{"Name":"coastalCover","ValueType":"Double"},{"Name":"processorName","ValueType":"String"},{"Name":"closedSeaCover","ValueType":"Integer"},{"Name":"openOceanCover","ValueType":"Integer"},{"Name":"orbitDirection","ValueType":"String"},{"Name":"processingDate","ValueType":"DateTimeOffset"},{"Name":"snowOrIceCover","ValueType":"Double"},{"Name":"lastOrbitNumber","ValueType":"Integer"},{"Name":"operationalMode","ValueType":"String"},{"Name":"processingLevel","ValueType":"String"},{"Name":"processingCenter","ValueType":"String"},{"Name":"processorVersion","ValueType":"String"},{"Name":"salineWaterCover","ValueType":"Double"},{"Name":"tidalRegionCover","ValueType":"Double"},{"Name":"platformShortName","ValueType":"String"},{"Name":"baselineCollection","ValueType":"String"},{"Name":"lastOrbitDirection","ValueType":"String"},{"Name":"processingBaseline","ValueType":"String"},{"Name":"continentalIceCover","ValueType":"Integer"},{"Name":"instrumentShortName","ValueType":"String"},{"Name":"relativeOrbitNumber","ValueType":"Integer"},{"Name":"freshInlandWaterCover","ValueType":"Double"},{"Name":"lastRelativeOrbitNumber","ValueType":"Integer"},{"Name":"platformSerialIdentifier","ValueType":"String"}]
## https://sentiwiki.copernicus.eu/web/olci-products
## https://sentiwiki.copernicus.eu/web/olci-products#S3-OLCI-Products-L1B
##
## Sentinel-3 SLSTR products in the CDSE catalogue
## https://sentiwiki.copernicus.eu/web/slstr-products
## https://sentiwiki.copernicus.eu/web/slstr-products#S3-SLSTR-Products-L1B-Observation-Mode
##
## MMM_OL_L_TTTTTT_yyyymmddThhmmss_YYYYMMDDTHHMMSS_YYYYMMDDTHHMMSS_[instance ID]_GGG_[class ID].SEN3
## MMM_SL_L_TTTTTT_yyyymmddThhmmss_YYYYMMDDTHHMMSS_YYYYMMDDTHHMMSS_[instance ID]_GGG_[class ID].SEN3
##
## MMM - mission ID (S3A, S3B)
## L - processing level (L1, L2)
## TTTTTT - product type (OL_1_EFR___, OL_1_ERR___, OL_2_LFR___, OL_2_LRR___, OL_2_WFR___)
## TTTTTT - product type (SL_1_RBT___)
## yyyymmddThhmmss - sensing start time
## YYYYMMDDTHHMMSS - sensing stop time
## YYYYMMDDTHHMMSS - product generation time
## instance ID - unique identifier of the product instance
## GGG - ground segment identifier (e.g. S3OP, S3PP)
## class ID - processing baseline identifier (e.g. 02.00, 03.01)
##
##
## S3A_OL_1_ERR____20260411T043233_20260411T051645_20260411T064044_2652_138_133______PS1_O_NR_004.SEN3
## S3B_OL_1_ERR____20260411T053450_20260411T061902_20260411T080526_2652_118_376______ESA_O_NR_004.SEN3

=begin
By default, if the orderby option is not used, the results are not ordered. If orderby option is used, additional orderby by id is also used, so that the results are fully ordered, and no products are lost while paginating through the results.
The acceptable arguments for this option: ContentDate/Start, ContentDate/End, PublicationDate, ModificationDate, in directions: asc, desc.

decODataClient --query cdse:s3:OL_1_ERR___  --time 2026-04-12T00:00:00.000Z | grep "S3B" | grep "NR"

S3B_OL_1_ERR____20260411T222438_20260411T230850_20260412T004831_2652_119_001______ESA_O_NR_004.SEN3
S3B_OL_1_ERR____20260412T000537_20260412T004949_20260412T023156_2652_119_002______ESA_O_NR_004.SEN3
S3B_OL_1_ERR____20260412T014635_20260412T023047_20260412T041248_2652_119_003______ESA_O_NR_004.SEN3
S3B_OL_1_ERR____20260412T032734_20260412T041146_20260412T055250_2652_119_004______ESA_O_NR_004.SEN3
S3B_OL_1_ERR____20260412T050833_20260412T055245_20260412T073727_2652_119_005______ESA_O_NR_004.SEN3

decODataClient --query cdse:s3:OL_1_EFR___  --time 2026-04-12T00:00:00.000Z | grep "S3B" | grep "NR"
S3B_OL_1_EFR____20260411T212524_20260411T212751_20260412T000234_0146_118_385_3960_ESA_O_NR_004.SEN3
S3B_OL_1_EFR____20260411T222438_20260411T222723_20260412T004441_0165_119_001_1440_ESA_O_NR_004.SEN3
S3B_OL_1_EFR____20260411T222723_20260411T223023_20260412T004035_0179_119_001_1620_ESA_O_NR_004.SEN3
S3B_OL_1_EFR____20260411T223023_20260411T223323_20260412T004153_0179_119_001_1800_ESA_O_NR_004.SEN3
S3B_OL_1_EFR____20260411T223323_20260411T223623_20260412T004138_0180_119_001_1980_ESA_O_NR_004.SEN3

decODataClient --query cdse:s3:OL_1_ERR___  --time 2026-04-12T00:00:00.000Z | grep "S3A" | grep "NR"
S3A_OL_1_ERR____20260411T230320_20260411T234731_20260412T010809_2651_138_144______PS1_O_NR_004.SEN3
S3A_OL_1_ERR____20260412T004419_20260412T012830_20260412T025157_2651_138_145______PS1_O_NR_004.SEN3
S3A_OL_1_ERR____20260412T022517_20260412T030929_20260412T043537_2652_138_146______PS1_O_NR_004.SEN3
S3A_OL_1_ERR____20260412T040616_20260412T045028_20260412T061620_2652_138_147______PS1_O_NR_004.SEN3
S3A_OL_1_ERR____20260412T054715_20260412T063127_20260412T075832_2652_138_148______PS1_O_NR_004.SEN3

S3B_OL_1_ERR____20260411T222438_20260411T230850_20260412T004831_2652_119_001______ESA_O_NR_004.SEN3
S3B_OL_1_EFR____20260411T222438_20260411T222723_20260412T004441_0165_119_001_1440_ESA_O_NR_004.SEN3
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

   API_URL_ODATA_COUNT_SENTINEL3_SL_1_RBT___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$top=1&$count=True&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'SL_1_RBT___')" 

   API_URL_ODATA_SELECT_BASE_SENTINEL3_OL_1_ERR___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')"

   API_URL_ODATA_SELECT_BASE_SENTINEL3_OL_1_EFR___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')"

   API_URL_ODATA_SELECT_BASE_SENTINEL3_SL_1_RBT___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'SL_1_RBT___')"

   API_URL_ODATA_SELECT_SENTINEL3_OL_1_ERR___  =\
    "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')&$orderby=ContentDate/Start asc&$top=1000"

   API_URL_ODATA_SELECT_SENTINEL3_OL_1_EFR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')&$orderby=ContentDate/Start asc&$top=1000"

   API_URL_ODATA_SELECT_SENTINEL3_SL_1_RBT___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'SL_1_RBT___')&$orderby=ContentDate/Start asc&$top=1000"

   API_URL_ODATA_SELECT_PAGING_BASE_SENTINEL3_OL_1_ERR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')"

   API_URL_ODATA_SELECT_PAGING_BASE_SENTINEL3_OL_1_EFR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')"

   API_URL_ODATA_SELECT_PAGING_BASE_SENTINEL3_SL_1_RBT___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'SL_1_RBT___')"

   API_URL_ODATA_SELECT_PAGING_SENTINEL3_OL_1_ERR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_ERR___')&$orderby=ContentDate/Start asc&$top=1000&$skip="

   API_URL_ODATA_SELECT_PAGING_SENTINEL3_OL_1_EFR___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'OL_1_EFR___')&$orderby=ContentDate/Start asc&$top=1000&$skip="

   API_URL_ODATA_SELECT_PAGING_SENTINEL3_SL_1_RBT___  =\
   "#{API_ROOT}/odata/v1/Products?$select=Name&$filter=Collection/Name eq 'SENTINEL-3' and Attributes/OData.CSC.StringAttribute/any(att:att/Name eq 'productType' and att/OData.CSC.StringAttribute/Value eq 'SL_1_RBT___')&$orderby=ContentDate/Start asc&$top=1000&$skip="

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
