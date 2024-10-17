#!/usr/bin/env ruby

require 'ctc/ReadInterfaceConfig'
require 'ctc/ReadFileSource'


module CTC

class CheckerIncomingFileConfig
       
   #--------------------------------------------------------------

   # Class constructor.
   # IN (string) Incoming file-type | wildcard to be checked.
   def initialize(filetype)
#     puts "initialize CheckerIncomingFileConfig ..."
      checkModuleIntegrity
      @ftReadConf = ReadInterfaceConfig.instance
      @ftReadFile = ReadFileSource.instance
      @filetype   = filetype
   end
   #-------------------------------------------------------------
   
   # ==== Main method of the class
   # ==== It returns a boolean True whether checks are OK. False otherwise.
   def check
      return checkDisseminationEntities
   end
   #-------------------------------------------------------------
   
   # Set debug mode on
   def setDebugMode
      @isDebugMode = true
      puts "CheckerIncomingFileConfig debug mode is on"
   end
   #-------------------------------------------------------------

private

   @isDebugMode       = false      
   @filetype          = nil

   #-------------------------------------------------------------

   # Check that everything needed by the class is present.
   def checkModuleIntegrity
      return
   end
   #-------------------------------------------------------------

   # Method that perform check
   def checkDisseminationEntities      
      bReturn             = true
      arrSenderEntities   = Array.new
      if @filetype.include?("*") == true or @filetype.include?("?") == true
         arrSenderEntities   = @ftReadFile.getEntitiesSendingIncomingFile(@filetype) 
      else
         arrSenderEntities   = @ftReadFile.getEntitiesSendingIncomingFileName(@filetype)
      end

      arrSenderEntities   = @ftReadFile.getEntitiesSendingIncomingFile(@filetype)  
      arrExternalEntities = @ftReadConf.getAllExternalMnemonics  
      arrSenderEntities.each{|x|
         if arrExternalEntities.include?(x) == false then
            puts
            puts "Error: Incoming Type #{@filetype} Received from #{x}: #{x} is not a configured I/F ! :-("
            puts
            bReturn = false
        end
     }
     return bReturn
   end
   #-------------------------------------------------------------

end # class

end # module

