#!/usr/bin/env ruby

require 'net/pop'


module CTC

class MailReceiver
	 
   #--------------------------------------------------------------

   # Class constructor.
   # host (IN) : string with the IP address or hostname
   # port (IN) : integer with port number
	# user (IN) : string with the username
	# pass (IN) : string with the password
   def initialize(host, port, user, pass, isSecure)
      @isDebugMode       = false
      @bConfigured       = false      
      @host              = host
      @port              = port
      @user              = user
      @pass              = pass
      @isSecure          = isSecure
      checkModuleIntegrity
   end
   #-------------------------------------------------------------
   
	# This method starts the POP connection.
   def init
      begin
         if @isSecure and @isSecure !="" then
            @popClient = Net::POP3.new(@host, 995)
            @popClient.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
         else
            @popClient = Net::POP3.new(@host)
         end
         @popClient.start(@user, @pass)
      rescue Exception => e
		   puts
         puts "POP3 Connection Refused ! =-("
         puts "Host   -> #{@host}"
         puts "Port   -> #{@port}"
         puts "User   -> #{@user}"
         puts "Pass   -> XXXXX"
         puts "Secure -> #{@isSecure}"
         puts 
         puts "Exception: #{e}"
         return false
      end
      @bConfigured = true
      return true
   end
   #-------------------------------------------------------------
   
   # Set debug mode on
   def setDebugMode
      @isDebugMode = true
      puts "MailReceiver Debug Mode is on"
   end
   #-------------------------------------------------------------
   
   # Is there mail ?
   # This method must be invoked after the init method
   def mail?
      if !@bConfigured then
         puts "Error in MailReceiver::mail?\n"
         exit(99)
      end
   return @popClient.mails.empty?
   end
   #-------------------------------------------------------------
	
   # Retrieve & Delete all mails in the server 
   def getAllMails(bDelete = false)
      arrMails = Array.new

         @popClient.each_mail{|m|			
               arrMails << m.pop
               if bDelete then
                  m.delete
               end
         }
         @popClient.finish

		return arrMails
   end
   #-------------------------------------------------------------

private

   @isDebugMode       = false      

   #-------------------------------------------------------------

   # Check that all needed to run is present
   def checkModuleIntegrity
      return
   end
   #-------------------------------------------------------------

end # class

end # module


