#!/usr/bin/env ruby

#########################################################################
#
# === Ruby source for #EventManager class
#
# === Written by DEIMOS Space S.L. (bolf)
#
# === Data Exchange Component -> Common Transfer Component
# 
# Git EventManager.rb,v $Id$ 1.4 2007/03/21 08:43:44 decdev Exp $
#
# === Module: Common Transfer Component // Class EventManager
#
# This class is in charge of processing different Events.
#
#########################################################################

require 'ctc/FTPClientCommands'
require 'ctc/SFTPBatchClient'
require 'ctc/ReadInterfaceConfig'
require 'ctc/CheckerFTPConfig'

module CTC

Events = [
            "ONSENDOK",
            "ONSENDNEWFILESOK",
            "ONSENDERROR",
            "ONRECEIVEOK",
            "ONRECEIVENEWFILESOK",
            "ONRECEIVENEWFILE",
            "ONRECEIVEERROR",
            "ONTRACKOK",
            "NEWFILE2INTRAY" 
            ]

class EventManagerDEPRECATED
   
   include CTC
   include FTPClientCommands
    
   #--------------------------------------------------------------

   # Class constructor.
   # IN (string) Mnemonic of the Entity.
   def initialize
      @isDebugMode = false
      checkModuleIntegrity
      @ftReadConf = ReadInterfaceConfig.instance
   end
   #-------------------------------------------------------------
   
   def trigger(interface, eventName, params = nil, log = nil)
      
      puts "EventManager::trigger #{eventName} - #{interface} - #{params}"
      
      eventMgr  = @ftReadConf.getEvents(interface)
      if eventMgr == nil then
         if @isDebugMode == true and log != nil then
            log.info("I/F #{interface}: EventManager::trigger => no events")
         end
         return
      end
      
      # if @isDebugMode == true and log != nil then
         log.debug("====================================")
         log.debug("EventManager::trigger #{eventName} - #{interface} - #{params}")
         log.debug("====================================")
      # end
      
      events = eventMgr[:arrEvents]
            
      events.each{|event|
         
         if eventName == event["name"] then
            cmd = event["cmd"]
            # Escape special XML characters.
            # At least '&' required for background execution
            anewCmd = cmd.sub!("&amp;", "&")
            if anewCmd != nil then
               cmd = anewCmd
            end
            if log != nil then
               log.info(cmd)
            end
            retVal = system(cmd)
            if @isDebugMode == true then
               log.debug("I/F #{interface}: Event #{eventName} Triggered for #{params}")
               log.debug("Executing command #{cmd}") 
            end
            if retVal == false then
               log.error("Error when executing #{cmd}")
            end
         end
      }
   end
   #-------------------------------------------------------------
   
   # Set debug mode on
   def setDebugMode
      @isDebugMode = true
      puts "EventManager debug mode is on"
   end
   #-------------------------------------------------------------

private

   #-------------------------------------------------------------

   # Check that everything needed by the class is present.
   def checkModuleIntegrity
      return true
   end
   #-------------------------------------------------------------

end # class

end # module

