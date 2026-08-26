#!/usr/bin/env ruby

require 'rexml/document'

require 'dec/DEC_Environment'

module DEC

class WriteXMLFile_REP_NOB_IN


   # -------------------------------------------------------------
  
   # Class constructor
   def initialize(directory, logger, debug = false)
      @targetDirectory     = directory
      @logger              = logger
      @isDebugMode         = debug
      
      checkModuleIntegrity
   end
   # -------------------------------------------------------------
   
   # Set the flag for debugging on
   def setDebugMode
      @isDebugMode = true
      @logger.debug('WriteXMLFile_REP_NOB_IN debug mode is on')
   end
   # -------------------------------------------------------------
   
   def setup(satPrefix, prjName, prjID, mission)
      @bSetup     = true
      @satPrefix  = satPrefix
      @prjName    = prjName
      @prjID      = prjID
      @mission    = mission
   end
   ## -----------------------------------------------------------

   def getFilename
      return @filename
   end

   ## -----------------------------------------------------------

   def writeFixedHeader
      
      @eeHeader   = @xmlRoot.add_element('Earth_Explorer_Header')
      header      = @eeHeader.add_element('Fixed_Header')

      xmlFilename             = header.add_element('File_Name')
      xmlFilename.text        = File.basename(@filename, ".xml")

      xmlDescription          = header.add_element('File_Description')
      xmlDescription.text     = 'Ingestion Report'

      xmlNotes                = header.add_element('Notes')
      xmlNotes.text           = 'DEC Ingestion Report'

      xmlMission              = header.add_element('Mission')
      xmlMission.text         = @mission

      xmlFileClass            = header.add_element('File_Class')
      xmlFileClass.text       = 'OPER'

      xmlFileType             = header.add_element('File_Type')
      xmlFileType.text        = 'REP_NOB_IN'

      xmlValPeriod            = header.add_element('Validity_Period')

      xmlValStart             = xmlValPeriod.add_element('Validity_Start')            
      xmlValStart.text        = @validityTime

      xmlValStop              = xmlValPeriod.add_element('Validity_Stop')            
      xmlValStop.text         = @validityTime

      xmlFileversion          = header.add_element('File_Version')
      xmlFileversion.text     = "0001"

      xmlSource               = header.add_element('Source')
      
      xmlSystem               = xmlSource.add_element('System')
      xmlSystem.text          = 'PDGS'
      
      xmlCreator              = xmlSource.add_element('Creator')
      xmlCreator.text         = 'DEC'

      xmlCreatorVersion       = xmlSource.add_element('Creator_Version')
      xmlCreatorVersion.text  = "#{DEC.class_variable_get(:@@version)}"

      xmlCreationDate         = xmlSource.add_element('Creation_Date')
      xmlCreationDate.text    = Time.now.utc.strftime("UTC=%Y-%m-%dT%H:%M:%S")

   end
   # -------------------------------------------------------------

   def writeVariableHeader
      header          = @eeHeader.add_element('Variable_Header')
   end
   # -------------------------------------------------------------
 
   def writeData(entity, pollingTime, arrHashData)
      if @bSetup == false then
         @logger.error("Error in WriteXMLFile_REP_NOB_IN::writeData !  :-O")
         @logger.error("method WriteXMLFile_REP_NOB_IN::setup has not been called !")
         raise "Error in WriteXMLFile_REP_NOB_IN::writeData !  :-O"
      end
	   @entity       = entity
      @pollingTime  = pollingTime.strftime("%Y%m%dT%H%M%S")
		@validityTime = pollingTime.strftime("UTC=%Y-%m-%dT%H:%M:%S")
		@filename     = %Q{#{@satPrefix}_OPER_REP_NOB_IN_#{@pollingTime}_#{@pollingTime}_#{@prjID}.xml}
      createXML()
      writeFixedHeader()
      writeVariableHeader()
      writeDataBlock(arrHashData)
      writeFile()
   end
   # -------------------------------------------------------------

   def writeDataBlock(arrHashData)
      @dataBlock   = @xmlRoot.add_element('Data_Block')
      @dataBlock.add_attribute('type', 'xml')
      list_received_files = @dataBlock.add_element('List_of_Received_Files')
      list_received_files.add_attribute('count', arrHashData.length)
      arrHashData.each{
         |receivedFile|
         received_file   = list_received_files.add_element('Received_File')
         received_file.text = "#{receivedFile['reception_date'].strftime('%Y-%m-%dT%H:%M:%S.%L')},#{receivedFile['interface']},#{receivedFile['filename']},#{receivedFile['size']},0"
      }
   end
   # -------------------------------------------------------------
   
private

   #-------------------------------------------------------------

   def initVariables
      return
   end
   #-------------------------------------------------------------

   # Check that everything needed is present
   def checkModuleIntegrity
      bDefined = true
      bCheckOK = true
      if bCheckOK == false then
         raise "WriteXMLFile_EOCFI_AUX_ORBRES::checkModuleIntegrity FAILED !"
      end
   end
   #-------------------------------------------------------------
   
   # Load the file into the internal struct File defined in the
   # class Constructor. See initialize.
   def createXML
      @xmlFile    = REXML::Document.new
      declaration = REXML::XMLDecl.new
      declaration.encoding = "UTF-8"
      @xmlFile << declaration
      @xmlRoot    = @xmlFile.add_element("Earth_Explorer_File")
      @xmlRoot.add_namespace('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
   end   
   #-------------------------------------------------------------
   
   def writeFile
      prevDir = Dir.pwd

      Dir.chdir(@targetDirectory)

      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      
      fh = File.new(@filename,"w")
      fh.puts formatter.write(@xmlFile,"")
      fh.close
      
      cmd = "xmllint --format #{@filename} > .kako.xml"
      # puts cmd
      system(cmd)
      
      cmd = "mv .kako.xml #{@filename}"
      # puts cmd
      system(cmd)

      Dir.chdir(prevDir)

   end
   #-------------------------------------------------------------
   
end # class

end # module
