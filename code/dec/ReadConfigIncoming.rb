#!/usr/bin/env ruby

require 'date'
require 'singleton'
require 'rexml/document'
require 'roman-numerals'

require 'cuc/DirUtils'


module DEC

class ReadConfigIncoming

   include Singleton
   include REXML
   include CUC::DirUtils
   
   ## -----------------------------------------------------------
   @@logger = nil
   def self.logger= fn
      @@logger = fn
   end
   ## -----------------------------------------------------------

   # Class constructor
   def initialize
      checkModuleIntegrity
		defineStructs
      loadData
   end
   ## -----------------------------------------------------------
   
   # Set the flag for debugging on
   def setDebugMode
      @isDebugMode = true
      if @@logger != nil then
         @@logger.debug("ReadConfigIncoming debug mode is on")
      else
         puts "ReadConfigIncoming debug mode is on"
      end
   end
   ## -----------------------------------------------------------

   ## Re-parse and re-load the structures
   def refresh
      loadData
   end
   ## -----------------------------------------------------------
   
   def getAllIncomingFiles
      arr = Array.new
      @@arrIncomingFiles.each{|incoming|
         arr << incoming[:filetype]
      }
      return arr
   end
   ## -----------------------------------------------------------
   
   def getIncomingDir(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:localInbox]
         end
      }
      return nil
   end
   ## -----------------------------------------------------------

   def getDownloadDirs(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:arrDownloadDirs]
         end
      }
      return Array.new
   end
   
   ## -------------------------------------------------------------
   
   def getSwitches(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:switches]
         end
      }
      return Array.new   
   end
   ## -------------------------------------------------------------
   
   def deleteDuplicated?(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:switches][:deleteDuplicated]
         end
      }
      return nil   
   end
   ## -------------------------------------------------------------

   def deleteDownloaded?(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:switches][:deleteDownloaded]
         end
      }
      return nil   
   end
   ## -------------------------------------------------------------

   def deleteUnknown?(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:switches][:deleteUnknown]
         end
      }
      return nil   
   end
   ## -------------------------------------------------------------

   def logUnknown?(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:switches][:logUnknown]
         end
      }
      return nil   
   end
   ## -------------------------------------------------------------

   def logDuplicated?(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:switches][:logDuplicated]
         end
      }
      return nil   
   end
   ## -------------------------------------------------------------

   def md5?(mnemonic)
      @@arrIncomingInterfaces.each{|interface|
         if interface[:mnemonic] == mnemonic then
            return interface[:switches][:md5]
         end
      }
      return nil   
   end
   ## -------------------------------------------------------------
     
   def getDIMCompress(name)
      puts
      puts "DEPRECATED METHOD: getDIMCompress !"
      puts
      return getInTrayCompress(name)
   end
   ## -------------------------------------------------------------
   
   def getInTrayExecution(name)
      @@arrIntrays.each{|dim|
         if name == dim[:name] then
            return dim[:execute]
         end
      }
      return false
   end 
   ## -------------------------------------------------------------

   def isUnCompressed?(arrName)
      raise if !arrName.class.to_s.include?("Array")
            
      arrName.each{|name|
         if getInTrayCompress(name) == nil then
            next
         end
         if getInTrayCompress(name) == "7z-x" or getInTrayCompress(name) == "7Z-X" then
            return true
         end
      }
      return false
   end
   
   ## -------------------------------------------------------------
   
   def isCompressed?(arrName)
      raise if !arrName.class.to_s.include?("Array")
            
      arrName.each{|name|
         if getInTrayCompress(name) == nil then
            next
         end
         if getInTrayCompress(name) == "7z" or getInTrayCompress(name) == "7Z" then
            return true
         end
      }
      return false
   end
   
   ## -------------------------------------------------------------
    
   def getInTrayCompress(name)
      @@arrIntrays.each{|dim|
         if name == dim[:name] then
            return dim[:compress]
         end
      }
      return false
   end
   ## -------------------------------------------------------------
   
   def getDIMInTray(name)
      puts
      puts "DEPRECATED METHOD: getDIMInTray !"
      puts
      return getInTrayDir(name)
   end
   
   ## -------------------------------------------------------------
     
   ## Get the In-Tray directory for a given DIM Name
   ## It returns the InTray Directory if present, otherwise false
   def getInTrayDir(name)
      
      # ------------------------------------------
      # 20170601 
      # Super - dirty patch to support compression
      # Depending on who is invoking this method, parameter can be a String
      # or a Hash which carries whether such DIM name is to be compressed
      
      dimName = ""
      
      if name.class.to_s == "Hash" then
         name.each_key{|key| dimName = key}
      else
         dimName = name
      end
      # ------------------------------------------
      
      @@arrIntrays.each{|dim|
         if dimName == dim[:name] then
            return expandPathValue(dim[:directory])
         end
      }
      return false
   end
   ## -------------------------------------------------------------
   
   # It returns true if the given name exists as a DIM
   def existDim?(name)
      @@arrIntrays.each{|dim|
         if dim[:name] == name then
            return true
         end
      }
      return false
   end
   ## -------------------------------------------------------------

   def getEntitiesSendingIncomingFile(fileType)
      return getEntitiesSendingIncomingFileName(fileType)
   end   
   ## -------------------------------------------------------------
   
   def getEntitiesSendingIncomingFileType(fileType)
      return getEntitiesSendingIncomingFileName(fileType)
   end
   ## -------------------------------------------------------------
   
   def getSourceOfFile(fileName, logger)
      arrEnt = Array.new
      @@arrIncomingFiles.each{|item|
         logger.debug("ReadConfigIncoming::getSourceOfFile(#{item[:filetype]} => #{fileName})")
         if File.fnmatch(item[:filetype], fileName) == true then
            return item[:fromList]
         end
      }   
   end
   ## -------------------------------------------------------------
   
   def getEntitiesSendingIncomingFileName(fileName)
      @@arrIncomingFiles.each{|item|
         if File.fnmatch(item[:filetype], fileName) == true then
            return item[:fromList]
         end
         if item[:filetype].include?("%Q{") == true and item[:filetype].include?("require") == true and item[:filetype].include?(";") == true then
            if File.fnmatch(eval(item[:filetype]), fileName) == true then
               return item[:fromList]
            end
         end
      }
   end
   ## -------------------------------------------------------------
   
   ## It returns an Array of the target directories (the In-Trays)
   ## for the given filetype.  
   def getTargetDirs4Filetype(filetype)
	   arrDirs = Array.new
      arrDims = getInTrays4Filetype(filetype)
      if arrDims == false then
		   if @isDebugMode == true then
            if @@logger != nil then
               @@logger.debug("No target In-Tray(s) for #{filetype} filetype in dec_incoming_files.xml")
            else
			      puts "No target In-Tray(s) for #{filetype} filetype in dec_incoming_files.xml" 
            end
			end
         return arrDirs
      end
      arrDims.each{|dim|
         intray = getInTrayDir(dim)
         if intray == false then
            puts "ERROR in #{@@configFile} file !"
            puts "#{dim} is not declared in the ListFilesDisseminated"
            puts "Please check your configuration file"
            puts
            exit(99)
         end
         arrDirs << getInTrayDir(dim)
      }
      return arrDirs      
   end
   
   ## -------------------------------------------------------------
   
   ## It returns an Array of the target directories (the DIMs In-Trays)
   ## for the given filename.     
   def getTargetDirs4Filename(filename)
	   arrDirs = Array.new
      arrDims = getDIMs4Filename(filename)
      if arrDims == false then
		   if @isDebugMode == true then
            if @@logger != nil then
               @@logger.debug("No target In-Tray(s) for #{filename} filename in dec_incoming_files.xml")
            else
			      puts "No target In-Tray(s) for #{filename} filename in dec_incoming_files.xml" 
            end
			end
         return arrDirs
      end
      arrDims.each{|dim|
         intray = getInTrayDir(dim)
         if intray == false then
            puts "ERROR in #{@@configFile} file !"
            puts "#{dim} is not declared in the ListFilesDisseminated"
            puts "Please check your configuration file"
            puts
            exit(99)
         end
         arrDirs << getInTrayDir(dim)
      }
      return arrDirs      
   end
   ## -----------------------------------------------------------
   
   ## It works for both files and filetypes
   def getDIMs(afile)
      return getDIMs4Filename(afile)
   end
   ## -----------------------------------------------------------
   def getDIMs4Filetype(afiletype)
      puts
      puts "DEPRECATED METHOD: getDIMs4Filetype !"
      puts
      return getInTrays4Filetype(afiletype)
   end
   ## -----------------------------------------------------------
   
   ## It returns an Array of the target DIMs for the given filetype.
   ## If the filetype does not exist, it returns false
   def getInTrays4Filetype(afiletype)
      return getFileField(afiletype, "arrIntrays") 
   end    
   ## -----------------------------------------------------------

   # This method has been implemented in order to deal with
   # Non Earth Explorer Files
   def getDIMs4Filename(afilename)
      return getFileField(afilename, "arrIntrays")
   end        
   ## -----------------------------------------------------------
      
   ## It retrieves all Intray methods
   def getIntrayNames
      arrDims = Array.new
      @@arrIntrays.each{|dim|
         arrDims << dim[:name]
      }
      return arrDims
   end
	## -----------------------------------------------------------
          
   # It retrieves all DIMs defined in the DIM_List
   def getAllDIMs
      puts
      puts "DEPRECATED METHOD: getAllDIMs !"
      puts
      return getIntrayNames
   end
	## -----------------------------------------------------------
	
	## It retrieves all FileTpyes declared in the ListFiles
	def getAllFileTypes
	   arrFiles = Array.new
	   @@arrFile2Intrays.each{|file|
		   arrFiles << file[:filetype]
		}
		return arrFiles
	end
   ## -----------------------------------------------------------

   # It returns true if the given filetype exists, otherwise false
   def existFileType?(afiletype)
      bExist = getFile(afiletype)
      if bExist != false then
         return true
      end
      return false   
   end
   ## -------------------------------------------------------------   
   
   # This method returns true if the given filename/filetype 
   # is disseminated as a hardlink to the DIMs In-Trays.
   # In case the given filetype does not exit it aborts
   def isHardLinked?(afile)
      return getFileField(afile, "hardlink")
   end
   ## -------------------------------------------------------------
   
   # Get a Parameter info for a given filename/filetype.
   # Filenames are recognized by the wildcard * at their end.
   def getFileField(afile, param)
      file = getFile(afile)
      if file == false then
         return false
      end
      return file[param]
   end
   ## -------------------------------------------------------------
   
   ## Get the information for a given filename or filetype
   ## Filenames are recognized by the wildcard * at their end.
   def getFile(afile)
      @@arrFile2Intrays.each{|file|
         bWildcard = false
         filetype  = file[:filetype]
         
         if filetype.include?("*") == true or filetype.include?("?") == true then
            bWildcard = true
         else
            bWildcard = false
         end
         
         if bWildcard == true then
            # Wildcard "*" can be placed not only at the end of the expresion
            # so all the elements must be included in the filename
            bRecognized = true
            arrWildCard = filetype.split("*")
            arrWildCard.each{|element|

               element = element.tr('\.', '$')
    
               tmp = element.sub!(/([$])/, "\\.")
               while tmp != nil do
   	            element = tmp
                  tmp = tmp.sub!(/([$])/, "\\.")
               end

               element = element.tr('?', '.')

               if afile.match("#{element}") == nil then
                  bRecognized = false
               end
            }   
            if bRecognized == true then
               return file
            end         
         
         else
            if afile == filetype then
               return file
            end
         end
      }
      return false
      puts "Error in ReadConfigIncoming::getFile"
      puts "#{afile} is not registered in dec_incoming_files.xml"
      exit(99)
   end
   ## -----------------------------------------------------------
   
   # This method checks the coherency of the config file.
   # - It checks that a DIM Name present in the FileList is defined
   # - as well in the DIM_List
   def checkCoherency
      return
   end
   ## -----------------------------------------------------------
   
   def getFileInfo(file, field)
   
      @@arrFile2Intrays.each{|file|
      
         bWildcard = false
         filetype  = file[:filetype]
         
         if filetype[-1] == "*" then
            bWildcard = true
            filetype.delete_at(-1)
         else
            bWildcard = false
         end
         
         if bWildcard == true then
            if filename.include?(filetype) then
               return file[field]
            end         
         else
            if file[:filetype] == filetype then
               puts file
               puts file[field]
               return file[field]
            end
         end
      }
      return false
      puts "Internal Error in DCC_ReadDimInTray::getFileInfo ! :-("
      puts
      exit(99)
  
   end 
   ## -----------------------------------------------------------

private

   @isDebugMode        = false
   
   @@arrOutgoingFiles  = nil
   @@arrIncomingFiles  = nil
   
   @@dynStruct         = nil
   @@configDirectory   = ""
   
   @@xmlOutFiles       = nil
   @@xmlInFiles        = nil

   @@monitorCfgFiles   = nil
   

   ## -------------------------------------------------------------
   ##
   ## Check that everything needed by the class is present.
   ##
   def checkModuleIntegrity
      
      bDefined = true
      bCheckOK = true
   
      if !ENV['DEC_CONFIG'] then
         puts "DEC_CONFIG environment variable not defined !  :-(\n"
         bCheckOK = false
         bDefined = false
      end
           
      if bDefined == true then      
         configDir = nil
         
         if ENV['DEC_CONFIG'] then
            configDir         = %Q{#{ENV['DEC_CONFIG']}}  
         end        
            
         @@configDirectory = configDir
        
         @@configFile = %Q{#{@@configDirectory}/dec_incoming_files.xml}        
         if !FileTest.exist?(@@configFile) then
            bCheckOK = false
            print("\n\n", @@configFile, " does not exist !  :-(\n\n" )
         end           
      end
         
      if bCheckOK == false then
        puts "ReadConfigIncoming::checkModuleIntegrity FAILED !\n\n"
        exit(99)
      end      
   end
   
   ## -------------------------------------------------------------
	##
   ## This method creates all the structs used
	##
   def defineStructs
   
      Struct.new("IncomingInterface", \
                  :mnemonic, \
                  :localInbox, \
                  :arrDownloadDirs, \
                  :switches)
                  
      Struct.new("IncomingFile", :filetype, :description, :fromList)
      Struct.new("Intray", :name, :directory, :compress, :execute)
      Struct.new("File2Intrays", :filetype, :hardlink, :arrIntrays)
      Struct.new("DownloadDir", :mnemonic, :directory, :depthSearch)
      
      Struct.new("Switches", \
                  :mnemonic, \
                  :deleteDownloaded, \
                  :deleteDuplicated, \
                  :deleteUnknown, \
                  :localDissemination, \
                  :logDuplicated, \
                  :logUnknown, \
                  :md5 \
                  )
	end
	## -------------------------------------------------------------

   ## Load the file into the an internal struct.
   ##
   ## The struct is defined in the class Constructor. See #initialize.
   def loadData
      hfileConfig                = File.new(@@configFile)
      xmlFile                    = REXML::Document.new(hfileConfig)
      @@arrIncomingInterfaces    = Array.new
      @@arrIncomingFiles         = Array.new
      @@arrIntrays               = Array.new
      @@arrFile2Intrays          = Array.new
      if @isDebugMode == true then
         puts "\nProcessing #{@@configFile}"
      end
      process(xmlFile)     
   end   
   ## -------------------------------------------------------------
   
   ## Process the xml file decoding all the file
   ## - xmlFile (IN): XML configuration file
   def process(xmlFile)
#      setDebugMode
      dimName              = ""
      dimInTray            = ""
      filetype             = ""
      filename             = ""
      hardlink             = ""
      
      ## ----------------------------------------
      
      path    = "Config/ListInterfaces/Interface"
      
      XPath.each(xmlFile, path){
         |interface|

         if_name                 = ""
         if_inbox                = ""
         if_switches             = nil
         bDeleteDownloaded       = nil
         bDeleteDuplicated       = nil
         bDeleteUnknown          = nil
         bLocalDissemination     = nil
         bLogDuplicated          = nil
         bLogUnknown             = nil
         bMD5                    = nil

         XPath.each(interface, "Name"){
             |name|
             if_name = name.text
         }

         XPath.each(interface, "LocalInbox"){
             |inbox|
             if_inbox = expandPathValue(inbox.text)
         }

         arrDownloadDirs = Array.new

         XPath.each(interface, "DownloadDirs/Directory"){
             |directory|
             depth = directory.attributes["DepthSearch"].to_i
             dir   = expandPathValue(directory.text)
             dir   = generatePathValue(dir)
             arrDownloadDirs << Struct::DownloadDir.new(if_name, dir, depth)
         }
         
         XPath.each(interface, "Switches"){
             |switch|
             
             XPath.each(switch, "DeleteDownloaded"){
                |name|
                if name.text.upcase == "TRUE" then
                   bDeleteDownloaded = true
                else
                   bDeleteDownloaded = false
                end
             }
             
             XPath.each(switch, "DeleteDuplicated"){
                |name|
                if name.text.upcase == "TRUE" then
                   bDeleteDuplicated = true
                else
                   bDeleteDuplicated = false
                end
             }
             
             XPath.each(switch, "DeleteUnknown"){
                |name|
                if name.text.upcase == "TRUE" then
                   bDeleteUnknown = true
                else
                   bDeleteUnknown = false
                end
             }
  
             XPath.each(switch, "LocalDissemination"){
               |name|
               if name.text.upcase == "TRUE" then
                  bLocalDissemination = true
               else
                  bLocalDissemination = false
               end
            }

             XPath.each(switch, "LogDuplicated"){
                |name|
                if name.text.upcase == "TRUE" then
                   bLogDuplicated = true
                else
                   bLogDuplicated = false
                end
             }
             
             XPath.each(switch, "LogUnknown"){
                |name|
                if name.text.upcase == "TRUE" then
                   bLogUnknown = true
                else
                   bLogUnknown = false
                end

             }

             XPath.each(switch, "MD5"){
               |name|
               if name.text.upcase == "TRUE" then
                  bMD5 = true
               else
                  bMD5 = false
               end

            }

             if_switches = Struct::Switches.new(if_name, \
                                    bDeleteDownloaded, \
                                    bDeleteDuplicated, \
                                    bDeleteUnknown, \
                                    bLocalDissemination, \
                                    bLogDuplicated, \
                                    bLogUnknown, \
                                    bMD5 )
            
         }

         
         
         @@arrIncomingInterfaces << Struct::IncomingInterface.new(if_name, \
                                                                  if_inbox, \
                                                                  arrDownloadDirs, \
                                                                  if_switches)
                                                                  

      }
      ## ----------------------------------------

      path    = "Config/DownloadRules/File"

      XPath.each(xmlFile, path){
         |file|
         
         description = ""
         filetype    = expandPathValue( file.attributes["Type"] )
         arrFromList = Array.new
            
         XPath.each(file, "Description"){
            |desc|
            description = desc.text
         }
           
         XPath.each(file, "FromList"){
            |list|
            XPath.each(list, "Interface/"){
               |mnemonic|
               arrFromList << mnemonic.text
            }
         }

         @@arrIncomingFiles << Struct::IncomingFile.new(filetype, description, arrFromList)

      }

      ## ----------------------------------------
     
      path    = "Config/DisseminationRules/ListIntrays/Intray"
      
      XPath.each(xmlFile, path){
          |dim|
             
          trayName   = ""   
          directory  = ""
          compress   = ""
          execute    = nil
                       
          XPath.each(dim, "Name"){
             |name|
             trayName = name.text
          }
  
          XPath.each(dim, "Directory"){
             |intray|
             directory = expandPathValue(intray.text)
          }	  

          compress = nil

          XPath.each(dim, "Compress"){
             |kompress|
             compress = kompress.text
          }	  

          XPath.each(dim, "Execute"){
             |exec|
             execute = exec.text
          }	  

            
          @@arrIntrays << Struct::Intray.new(trayName, directory, compress, execute)      
      
      }
 
      ## ----------------------------------------
      
      path    = "Config/DisseminationRules/ListFilesDisseminated/File"
      
      XPath.each(xmlFile, path){
         |file|
         
         filetype    = file.attributes["Type"]
         hardlink    = nil
         arrIntrays  = Array.new
         
         XPath.each(file, "HardLink"){
            |link|
            hardlink = (link.text.downcase == "true")
         }
                   
         XPath.each(file, "ToList"){
            |to|
            XPath.each(to, "Intray"){
               |dim|
               arrIntrays << dim.text
            } 
         }    
	      @@arrFile2Intrays << Struct::File2Intrays.new(filetype, hardlink, arrIntrays)
      }
      
      ## ----------------------------------------
      
        
   end
   ## -------------------------------------------------------------
      
   ## I can not understand why there is not a method in REXML that provides
   ## you the Key for a given Attribute
   def getKey(xpath)
      arrPath = xpath.split("@")
      return arrPath[1]
   end
   ## -------------------------------------------------------------

end # class

end # config
