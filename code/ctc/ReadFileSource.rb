#!/usr/bin/env ruby

require 'singleton'
require 'rexml/document'

module CTC

class ReadFileSource

   include Singleton
   include REXML
   include CTC
   
   #-------------------------------------------------------------
  
   # Class constructor
   def initialize
      @@isModuleOK        = false
      @@isModuleChecked   = false
      @isDebugMode        = false
      @@handlerXmlFile    = nil          
      checkModuleIntegrity
      defineStructs
      loadData
   end
   #-------------------------------------------------------------
   
   # Set the flag for debugging on
   def setDebugMode
      @isDebugMode = true
      puts "ReadFileDestination debug mode is on"
   end
   #-------------------------------------------------------------
   
   # Reload data from files
   #
   # This is the method called when the config files are modified
   def update
      if @isDebugMode then 
         print("\nReceived Notification that the config files have changed\n")
      end   
      loadData
   end
   #-------------------------------------------------------------
   
   # Get all files that are sent by an Internal Entity, i.e. DCC
   # - mnemonic (IN): Entity name
   def getFromListOutgoingFiles(mnemonic)
      if @isDebugMode then 
         print("\nGet Outgoing files FROM  ", mnemonic, " facility \n")
      end   
      return getFiles(@@FT_OUTGOING, @@FT_FROM, mnemonic)
   end
   #-------------------------------------------------------------
   
   # Get all files that are received by an External Entity, i.e. PDS
   # - mnemonic (IN): Entity name
   def getToListOutgoingFiles(mnemonic)
      if @isDebugMode then 
         print("\nGet Outgoing files TO ", mnemonic, " facility \n")
      end            
      return getFiles(@@FT_OUTGOING, @@FT_TO, mnemonic)
   end   
   #-------------------------------------------------------------
   
   # Get all files that are received by an Internal Entity, i.e. DCC
   # - mnemonic (IN): Entity name
   def getToListIncomingFiles(mnemonic)
      if @isDebugMode then 
         print("\nGet Incoming files TO  ", mnemonic, " facility \n")
      end   
      return getFiles(@@FT_INCOMING, @@FT_TO, mnemonic)
   end   
   #-------------------------------------------------------------
   
   # Get all files that are sent by an External Entity, i.e. PDS
   # - mnemonic (IN): Entity name
   def getFromListIncomingFiles(mnemonic)
      if @isDebugMode then 
         print("\nGet Incoming files FROM  ", mnemonic, " facility \n")
      end   
      return getFiles(@@FT_INCOMING, @@FT_FROM, mnemonic)
   end 
   #-------------------------------------------------------------
   
   # Get all Entities (internal and external Entities) Receiving
   # an outgoing file of a given FileType
   # - filetype (IN): File type
   def getEntitiesReceivingOutgoingFile(filetype)
      if @isDebugMode then 
         print("\nGet External Entities which Receive the ", filetype, " file type \n")
      end
      return getMnemonics(@@FT_OUTGOING, @@FT_TO, filetype)
   end
   #-------------------------------------------------------------   
   
   # Get all Internal Entities Receiving
   # an incoming file of a given FileType
   # - filetype (IN): File type
   def getEntitiesReceivingIncomingFile(filetype)
      if @isDebugMode then 
         print("\nGet Internal Entities which Receive the ", filetype, " file type \n")
      end   
      return getMnemonics(@@FT_INCOMING, @@FT_TO, filetype)
   end
   #-------------------------------------------------------------
   
   #
   def getCompressMethod(entity, filetype)   
      @@arrOutgoingFiles.each{|element|
         if element[:fileType] == filetype then
            element[:toList].each{|anEntity|
               if anEntity[:mnemonic] == entity then
                  return anEntity[:compressMethod]
               end
            }
         end
      }
      return false
   end
   #-------------------------------------------------------------

   def getDeliveryMethods(entity, filetype)
      @@arrOutgoingFiles.each{|element|
         if element[:fileType] == filetype then
            element[:toList].each{|anEntity|
               if anEntity[:mnemonic] == entity then
                  return anEntity[:deliveryMethods]
               end
            }
         end
      }
      return false
   end
   #-------------------------------------------------------------

   #
   def isCompressed?(entity, filetype)   
      @@arrOutgoingFiles.each{|element|
         if element[:fileType] == filetype then
            element[:toList].each{|anEntity|
               if anEntity[:mnemonic] == entity then
                  return true
               end
            }
         end
      }
      return false
   end
   #------------------------------------------------------------
   
   def isMnemonicAddedToName?(entity, filetype, bFileType = true)
      element = getIncomingFileStruct(entity, filetype, bFileType)
      if element == nil then
         return false
         puts
         puts "Fatal Error in ReadFileSource::isMnemonicAddedToName? ! :-("
         puts
         if bFileType == false then
            puts "File #{filetype} seems not to be retrieved from #{entity} !"
         else
            puts "Type #{filetype} seems not to be retrieved from #{entity} !"
         end
         puts
         exit(99)
      end
      return element[:addMnemonic2Name]
   end
   #-------------------------------------------------------------
   
   # Get all Interfaces which have available 
   # an incoming file of a given FileType
   # - filetype (IN): File type
   def getEntitiesSendingIncomingFile(filetype)
      if @isDebugMode then 
         print("\nGet Interfaces which have available files of ", filetype, " file type \n")
      end
      if filetype.include?("*") == true or filetype.include?("?") == true then
         return getMnemonics(@@FT_INCOMING, @@FT_FROM, filetype, false)
      else
         return getMnemonics(@@FT_INCOMING, @@FT_FROM, filetype)
      end
   end
   #-------------------------------------------------------------

   # Get all Interfaces which have available 
   # an incoming file of a given FileType
   # - filetype (IN): File type
   def getEntitiesSendingIncomingFileType(filetype)
      if @isDebugMode then 
         print("\nGet Interfaces which have available files of ", filetype, " file type \n")
      end   
      return getMnemonics(@@FT_INCOMING, @@FT_FROM, filetype)
   end
   #-------------------------------------------------------------

   # Get all External Entities which Send 
   # an incoming file of a given FileType
   # - filetype (IN): File type
   def getEntitiesSendingIncomingFileName(filename)
      if @isDebugMode then 
         print("\nGet Interfaces which have available files with name ", filename, "  \n")
      end   
      return getMnemonics(@@FT_INCOMING, @@FT_FROM, filename, false)
   end
   #-------------------------------------------------------------

   
   # Get All Internal Entities which Send
   # an outgoing file of a given FileType    
   # - filetype (IN): File type
   def getEntitiesSendingOutgoingFile(filetype)
      if @isDebugMode then 
         print("\nGet Internal Entities which Send the ", filetype, " file type \n")
      end   
      return getMnemonics(@@FT_OUTGOING, @@FT_FROM, filetype)
   end
   #-------------------------------------------------------------

   # Get All Internal Entities which Send
   # an outgoing file of a given FileType    
   # - filetype (IN): File type
   def getEntitiesSendingOutgoingFile(filetype)
      if @isDebugMode then 
         print("\nGet Internal Entities which Send the ", filetype, " file type \n")
      end   
      return getMnemonics(@@FT_OUTGOING, @@FT_FROM, filetype)
   end
   #-------------------------------------------------------------
   
   # Get an Array of all FileTypes registered in ft_outgoing_files.xml
   def getAllOutgoingTypes
      return getFiles(@@FT_OUTGOING, @@FT_TO, nil)
   end
   #-------------------------------------------------------------
   
   # DEPRECATED, please use getAllOutgoingTypes
   # Get an Array of all FileTypes registered in ft_outgoing_files.xml
   def getAllOutgoingFiles
      return getAllOutgoingTypes
   end
   #-------------------------------------------------------------
   
   # Get an Array of all FileTypes registered in ft_incoming_files.xml
   def getAllIncomingFiles
      return getFiles(@@FT_INCOMING, @@FT_FROM, nil)
   end
   #-------------------------------------------------------------

   # Get an Array of all FileTypes registered in ft_incoming_files.xml
   def getAllIncomingFileNames
      return getFiles(@@FT_INCOMING, @@FT_FROM, nil, false)
   end
   #-------------------------------------------------------------  
   
   def getDescription(filetype)
      @@arrIncomingFiles.each{|x|
         if x[:fileType] == filetype then
            return x[:description].to_s
         end
      }
      puts "\nDCC_ReadFileDestination::getDescription INTERNAL Error"   
   end
   #-------------------------------------------------------------   
   
private

   @@isModuleOK        = false
   @@isModuleChecked   = false
   @isDebugMode        = false
   
   @@arrOutgoingFiles  = nil
   @@arrIncomingFiles  = nil
   
   @@dynStruct         = nil
   @@configDirectory   = ""
   
   @@xmlOutFiles       = nil
   @@xmlInFiles        = nil

   @@monitorCfgFiles   = nil
   
   # Class constants
   @@FT_INCOMING = 1
   @@FT_OUTGOING = 2
   @@FT_FROM     = 1
   @@FT_TO       = 2

   #-------------------------------------------------------------

   # Check that everything needed is present
   def checkModuleIntegrity
      
      bDefined = true
      bCheckOK = true
   
      if !ENV['DCC_CONFIG'] and !ENV['DEC_CONFIG'] then
        puts "\nDCC_CONFIG environment variable not defined !  :-(\n\n"
        bCheckOK = false
        bDefined = false
      end
      
      if bDefined == true then
        configDir = nil
        if ENV['DEC_CONFIG'] then
           configDir         = %Q{#{ENV['DEC_CONFIG']}}  
        else
           configDir         = %Q{#{ENV['DCC_CONFIG']}}  
        end
             
        @@configDirectory = configDir
                        
        configFile = %Q{#{configDir}/ft_incoming_files.xml}        
        if !FileTest.exist?(configFile) then
           bCheckOK = false
           print("\n\n", configFile, " does not exist !  :-(\n\n" )
        end        
        
      end
      if bCheckOK == false then
        puts "ReadFileSource::checkModuleIntegrity FAILED !\n\n"
        exit(99)
      end      
   end
   #-------------------------------------------------------------
   
   def defineStructs
      # Struct.new("OutgoingFile", :fileType, :description, :toList)
      Struct.new("IncomingFilename", :fileName, :description, :fromList, :toList, :addMnemonic2Name)
      @@dynStructIn  = Struct.new("IncomingFile", :fileType, :description, :fromList, :toList, :addMnemonic2Name)
      Struct.new("DeliveryEntity", :mnemonic, :compressMethod, :deliveryMethods)
   end
   #-------------------------------------------------------------
   
   # Load the file into the internal struct File defined in the
   # class Constructor. See initialize.
   def loadData
      incomingFilename = %Q{#{@@configDirectory}/ft_incoming_files.xml}
      fileIncoming     = File.new(incomingFilename)
      xmlIncoming      = REXML::Document.new(fileIncoming)
      @@arrOutgoingFiles      = Array.new
      @@arrIncomingFiles      = Array.new
      @@arrIncomingFilenames  = Array.new
      if @isDebugMode == true then
         puts("\nProcessing Incoming Files")
      end     
      processFileTypeLists(xmlIncoming, @@arrIncomingFiles, false)
   end   
   #-------------------------------------------------------------
   
   #-------------------------------------------------------------
   # Process File
   # - xmlFile (IN): XML file
   # - arrFile (OUT): 
   def processFileTypeLists(xmlFile, arrFiles, outgoing)
      description    = ""
      newFile        = nil
      newFilename    = nil
      newFiletype    = nil  
      compressMethod = nil
      arrFromList    = Array.new
      arrToList      = Array.new
      
      file = XPath.each(xmlFile, "FileList/File"){      
             |file|
             
             bFound = false
             file.attributes.each_attribute{|attr|
               if attr.name == "Type" then
                  bFound = true
               end   
             }

             if bFound == false then
                puts
                puts file
                puts
                puts "Attribute Type for Element File has not been found in ft_incoming_file.xml"
                puts
                puts "Majo, me temo que fatal error ! :-p"
                puts
                exit(99)
             end

             bAddMnemonic2Name = false
             # Append Mnemonic to retrieved Filename?
             file.attributes.each_attribute{|attr|
               if attr.name == "AddMnemonic2Name" then
                  if file.attributes["AddMnemonic2Name"].downcase == "yes" then
                     bAddMnemonic2Name = true
                  end
                  break
               end   
             }

             # Distinguish between Name or Type
             filetype = file.attributes["Type"]
            
             if filetype.include?("*") == true or filetype.include?("?") == true then
                filename = filetype
                filetype = nil
             end

             if filetype == nil and filename == nil then
                puts
                file.attributes.each_attribute{|attr|
                   puts "File Attribute -> #{attr.name}"
                }
                puts
                puts file
                puts
                puts "XML element File must contain a Wildcard or Type Attribute"
                puts "Error in ReadFileDestination::processFileTypeLists ! :-("
                puts
                exit(99)
             end

             XPath.each(file, "Description"){
                 |desc|
                 description = desc.text
             }
           
             XPath.each(file, "FromList"){
                 |list|
                 arrFromList = Array.new
                 XPath.each(list, "Interface/"){
                    |mnemonic|
                    arrFromList << mnemonic.text
                 }
             }

             # Read Compression Flag
             if outgoing == true then
	             XPath.each(file, "CompressMethod"){
		             |compress|
		             compressMethod = compress.text
		          }
	          end

             if outgoing == true
	             newFile = Struct::OutgoingFile.new(file.attributes["Name"], compressMethod, arrFromList, arrToList)
             else
                if filename != nil then
                   newFilename = Struct::IncomingFilename.new(filename, description, arrFromList, arrToList, bAddMnemonic2Name)
                end
                if filetype != nil then
                   newFiletype = @@dynStructIn.new(filetype, description, arrFromList, arrToList, bAddMnemonic2Name)
	                newFile = @@dynStructIn.new(filetype, description, arrFromList, arrToList, bAddMnemonic2Name)
                end
	          end
	          
             #--------------------------------------------------------
             if filetype != nil then
                # Check duplicated elements, in case of finding them, abort
                arrFiles.each{|element|
                   if element[:fileType] == file.attributes["Name"] then
                      puts "Error in DCC Configuration !  :-("
                      print "#{element[:fileType]} type is duplicated in "
                      if outgoing == true then
                         print "ft_outgoing_files.xml"
                      else
                         print "ft_incoming_files.xml" 
                      end
                      puts
                      puts
                      exit(99)
                   end
                }

                arrFiles << newFiletype

                if @isDebugMode == true then
                   puts newFiletype
                end

             end
             #--------------------------------------------------------
             if filename != nil then
                @@arrIncomingFilenames.each{|element|
                   if element[:fileName] == filename then
                      puts "Error in DCC Configuration !  :-("
                      print "#{element[:fileName]} Name is duplicated in "
                      if outgoing == true then
                         print "ft_outgoing_files.xml"
                      else
                         print "ft_incoming_files.xml" 
                      end
                      puts
                      puts
                      exit(99)               
                   end
                }

                @@arrIncomingFilenames << newFilename

                if @isDebugMode == true then
                   puts newFilename
                end


             end
             #--------------------------------------------------------
	          

      }
            
   end
   #-------------------------------------------------------------
      
   def fillDeliveryEntityStruct(mnemonic, compress, arrDissMethods)
      return Struct::DeliveryEntity.new(mnemonic, compress, arrDissMethods)
   end
   #-------------------------------------------------------------
   
   # Get Files which are sent/received from/to an Entity
   # - inout (IN): Flag to get incoming or outgoing files
   # - list (?): ???
   # - mnemonic (IN): Entity name
   def getFiles(inout, list, mnemonic, bFileType = true)
      arrResult = Array.new
      arrFiles  = Array.new
      if inout == @@FT_INCOMING then
         if bFileType == true then
            arrFiles = @@arrIncomingFiles
         else
            arrFiles = @@arrIncomingFilenames
         end
      else
         arrFiles = @@arrOutgoingFiles
      end
      nFiles    = arrFiles.length            
      0.upto(nFiles-1) do |i|
         file    = arrFiles[i]
         if list == @@FT_FROM then
            arrFrom = file[:fromList]
         else
            arrFrom = file[:toList]
         end      
         nFrom   = arrFrom.length
         0.upto(nFrom-1) do |j|
            if arrFrom[j] == mnemonic or mnemonic == nil then
               if bFileType == true then
                  arrResult << arrFiles[i][:fileType]
               else
                  arrResult << arrFiles[i][:fileName]
               end
            end         
         end
      end
      return arrResult.uniq.sort
   end
   #-------------------------------------------------------------
   
   def getIncomingFileStruct(entity, filetype, bFileType = true)
      if bFileType == true
         arrFiles = @@arrIncomingFiles
      else
         arrFiles = @@arrIncomingFilenames
      end
      arrFiles.each{|element|
         # if check is performed by filetype
         if bFileType == true then
            if filetype == element[:fileType] then
               if element[:fromList].include?(entity) == true then
                  return element
               end
            end
         else
            wildcard = element[:fileName]
            if File.fnmatch(wildcard, filetype) == true then
               if element[:fromList].include?(entity) == true then
                  return element
               end
            end
         end
      }
      return nil
   end
   #-------------------------------------------------------------

   # Get the Mnemonics which send/receive to/from a file
   # - inout (IN): ???
   # - list (?): ???
   # - filetype (IN): ???
   def getMnemonics (inout, list, filetype, bFileType = true)
      arrResult = Array.new
      arrFiles  = Array.new
      if inout == @@FT_INCOMING then
         if bFileType == true
            arrFiles = @@arrIncomingFiles
         else
            arrFiles = @@arrIncomingFilenames
         end
      else
         arrFiles = @@arrOutgoingFiles
      end
      nFiles  = arrFiles.length            
      0.upto(nFiles-1) do |i|
         if bFileType == true         
            if filetype == arrFiles[i][:fileType] then
               if list == @@FT_TO then
                  arrEnts = Array.new
                  arrFiles[i][:toList].each{|anEntity|
                     arrEnts << anEntity[:mnemonic]
                  }   
                  return arrEnts
               else
                  return arrFiles[i][:fromList]
               end            
            end
         else
            # Perform the matching of wildcards
            wildcard = arrFiles[i][:fileName]

            if File.fnmatch(wildcard, filetype) == true then
               if list == @@FT_TO then
                  arrEnts = Array.new
                  arrFiles[i][:toList].each{|anEntity|
                     arrEnts << anEntity[:mnemonic]
                  }   
                  return arrEnts
               else
                  return arrFiles[i][:fromList]
               end            
            end
         end

      end
      return
   end
   #-------------------------------------------------------------

end # class


end # module
