#!/usr/bin/env ruby

require 'ctc/ReadInterfaceConfig'
require 'ctc/ReadMailNotification'

module CTC

class CheckerMailNotification
   
   NotifyEvents = ["SuccessDelivery" ,"ErrorDelivery" ,"OnDetection", "OnReception"] 
   
   include CTC 
   #--------------------------------------------------------------

   # Class constructor.
   def initialize
      checkModuleIntegrity
      @notifyReadConf   = ReadMailNotification.instance
      entityReadConf    = ReadInterfaceConfig.instance
      @arrConfEntities  = entityReadConf.getAllExternalMnemonics
      @arrNotifEntities = @notifyReadConf.getAllEntities
   end
   #-------------------------------------------------------------
   
   # Main method of the class which performs the check.
   def check     
      retVal = true
      @arrNotifEntities.each{|entity|
         # Check Entities vs interfaces.xml to see whether 
         # an entity is configured or not
         if @arrConfEntities.include?(entity) == false then
            puts "\nError in Notify2 #{entity} I/F ! :-("
            puts "#{entity} is not a configured I/F"
            retVal = false
            next
         end
         arrEvents = @notifyReadConf.getNotificationEvents(entity)
         # Check Events
         arrEvents.each{|event|
            if NotifyEvents.include?(event) == false then
               retVal = false
               puts "\nNotify2[#{entity}] Event #{event} is unknown"
               puts "Implemented Events are:"
               puts NotifyEvents
            end
            
            arrAddresses = @notifyReadConf.getRecipients(entity, event)
            
            # Check whether the addresses are a valid email one
            arrAddresses.each{|email|
               if email.include?("@") == false or email.include?(".") == false then
                  retVal = false
                  puts "\nNotify2[#{entity}] -> #{event}  #{email} is not a valid email address"
               end
            }
            
         }
      }
      return retVal
   end
   #-------------------------------------------------------------

   # Set debug mode on
   def setDebugMode
      @isDebugMode = true
      puts "CheckerMailNotification debug mode is on"
   end
   #-------------------------------------------------------------
   
private

   #-------------------------------------------------------------

   # Check that everything needed by the class is present.
   def checkModuleIntegrity
      return
   end
   #-------------------------------------------------------------   

end # class

end # module

