#!/usr/bin/env ruby

require 'ctc/ReadInterfaceConfig'
require 'ctc/ReadFileSource'
require 'cuc/PackageUtils'

module CTC

class CheckerOutgoingFileConfig
   
   include CTC
   include CUC::PackageUtils
   #--------------------------------------------------------------

   # Class constructor.
   # IN (string) configuration outgoing file-type to be checked.
   def initialize(filetype, wildcard = false)
#     puts "initialize CheckerOutgoingFileConfig ..."
      checkModuleIntegrity
      @ftReadConf = ReadInterfaceConfig.instance
      @ftReadFile = ReadFileDestination.instance
      @filetype   = filetype
      @wildcard   = wildcard
   end
   #-------------------------------------------------------------
   
   # ==== Main method of the class
   # ==== It returns a boolean True whether checks are OK. False otherwise.
   def check
      bRet = checkTargetEntities
      if bRet == true then
         bRet = checkCompressMethod
      else
         checkCompressMethod
      end
      return bRet
   end
   #-------------------------------------------------------------

   # Set debug mode on
   def setDebugMode
      @isDebugMode = true
      puts "CheckerOutgoingFileConfig debug mode is on"
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
   
   def checkTargetEntities      
     bReturn          = true     
     arrClients       = @ftReadConf.getAllExternalMnemonics
     arrDissEntities  = @ftReadFile.getEntitiesReceivingOutgoingFile(@filetype)
          
     arrDissEntities.each{|x|
         if arrClients.include?(x) == false then
            puts "Error: Outgoing Type #{@filetype} is Sent to #{x}: #{x} is not a configured I/F ! :-("
            puts
            bReturn = false
            return bReturn
         end
         # Check whether there is a proper mail account configured

         if @wildcard == false then
            arrDelMethods = @ftReadFile.getDeliveryMethods(x, @filetype)
         else
            arrDelMethods = @ftReadFile.getDeliveryMethodsForNames(x, @filetype)
         end 

         arrAllowedMethods = @ftReadFile.getAllowedDeliveryMethods


         arrDelMethods.each{|method|
            
            if arrAllowedMethods.include?(method) == false then
               puts "Delivery method #{method} for #{@filetype} is not recognized ! :-("
               bReturn = false
            end

            if method == "email" or method == "mailbody" then
               listMail = @ftReadConf.getMailList(x)
               if listMail == nil then
                  puts "Error: Missing Email address(es) for #{x} I/F. Email delivery of #{@filetype} will fail ! :-("
                  puts
                  bReturn = false
               else
                  if listMail.length == 0 then
                     puts "Error: Missing Email address(es) for #{x} I/F. Email delivery of #{@filetype} will fail ! :-("
                     puts
                     bReturn = false
                  end               
               end
            end
         }
     }     
     return bReturn
   end
   #-------------------------------------------------------------   

   def checkCompressMethod
      arrDissEntities = @ftReadFile.getEntitiesReceivingOutgoingFile(@filetype)
      
      arrDissEntities.each{|x|

         if @wildcard == false then
            compressMethod = @ftReadFile.getCompressMethod(x, @filetype)
         else
            compressMethod = @ftReadFile.getCompressMethodForNames(x, @filetype)
         end

         if CompressMethods.include?(compressMethod) == false then
            puts
            puts "Compress Method #{compressMethod} for #{@filetype} when sending to #{x} is not recognized ! :-("
            puts
            bReturn = false
         end
      }
      return true
   end
   #-------------------------------------------------------------

end # class

end # module
