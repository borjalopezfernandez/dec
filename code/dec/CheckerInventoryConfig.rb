#!/usr/bin/env ruby

require 'dec/ReadInterfaceConfig'

module DEC

class CheckerInventoryConfig
    
   ## -----------------------------------------------------------

   ## Class constructor.
   def initialize(logger = nil)
      @logger = logger
      checkModuleIntegrity
      @decReadConf    = ReadInterfaceConfig.instance
   end
   ## -----------------------------------------------------------
   
   ## Main method of the class
   ## It returns a boolean True whether checks are OK. False otherwise.
   def check(interface = "")     
      retVal   = true      
      arrEnts  = @decReadConf.getAllMnemonics

      arrEnts.each{|x|
         if interface != "" and interface != x then
            next
         end
         # Interface.where(["name = ?", x]).first
      
         begin
            if Interface.find_by_name(x) != nil then
               @logger.info("[DEC_003] I/F #{x}: interface is correctly declared in DEC/Inventory #{'1F44D'.hex.chr('UTF-8')}")
               retVal = true
            else
               @logger.error("[DEC_605] I/F #{x}: such is not a registered I/F in db #{'1F480'.hex.chr('UTF-8')}")
               retVal = false
            end
         rescue Exception => e
            @logger.error("[DEC_798] Fatal Error : DEC/Inventory #{e.to_s}")
            return false
         end
      }
      return retVal
   end
   ## -----------------------------------------------------------

   ## Set debug mode on
   def setDebugMode
      @isDebugMode = true
      @logger.debug("CheckerInventoryConfig debug mode is on")
   end
   ## -----------------------------------------------------------

private

   @isDebugMode       = false      

   ## -----------------------------------------------------------

   ## Check that everything needed by the class is present.
   def checkModuleIntegrity

      if !ENV['DEC_DATABASE_NAME'] then
         @logger.error("DEC_DATABASE_NAME environment variable not defined !  #{'1F480'.hex.chr('UTF-8')}")
         bCheckOK = false
         bDefined = false
         @logger.error("Error in CheckerInventoryConfig::checkModuleIntegrity !")
         exit(99)
      end
      
      if ENV['DEC_DATABASE_NAME'] then
         require 'dec/DEC_DatabaseModel'
      end
     
   end
   ## -----------------------------------------------------------

end # class

end # module

