#!/usr/bin/env ruby

#########################################################################
#
# === Ruby source for #DatabaseModel class
#
# === Written by DEIMOS Space S.L. (bolf)
#
# === Data Exchange Component -> Data Distributor Component
# 
# CVS: $Id: DatabaseModel.rb,v 1.12 2007/12/18 18:34:03 decdev Exp $
#
# module DBM
#
#########################################################################

require 'rubygems'
require 'active_record'

dbAdapter   = ENV['DCC_DB_ADAPTER']
dbName      = ENV['DCC_DATABASE_NAME']
dbUser      = ENV['DCC_DATABASE_USER']
dbPass      = ENV['DCC_DATABASE_PASSWORD']

ActiveRecord::Base.establish_connection(
         :adapter    => dbAdapter,
         :host       => "localhost", 
         :database   => dbName,
         :username   => dbUser,
         :password   => dbPass, 
         :timeout    => 60000
         )

#=====================================================================

class Interface < ActiveRecord::Base
   validates_presence_of   :name
   validates_uniqueness_of :name
end

#=====================================================================

class ReceivedFile < ActiveRecord::Base
   belongs_to  :interface
   # attr_accessor :filename, size, reception_date, protocol
end

#=====================================================================

class TrackedFile < ActiveRecord::Base
   belongs_to  :interface
end

#=====================================================================


#=====================================================================
# Class SentFile that maps SENT_FILES tables

class SentFile < ActiveRecord::Base
   # belongs_to  :interface
   
   #-----------------------------------------------------------
   
   def SentFile.hasAlreadyBeenSent?(file, entity, deliveryMethod)
      someFiles = SentFile.find_all_by_filename(file)
      someFiles.each{|aFile|
       #  if aFile.interface.name == entity then
         if aFile.interface == entity then
            methods = aFile.delivered_using
            if methods == nil then
               return false
            end
            if methods.include?(deliveryMethod) == true then
               return true
            else
               return false
            end
         end
      }
   end
   
   #-----------------------------------------------------------
   
   def SentFile.setBeenSent(file, interface, deliveryMethod, hParams=nil)
     
 
      # Verify all the "extra" params exist in SENT_FILES table 
      if hParams != nil then
         if hParams.class.to_s != "Hash" then
            puts hParams.class
            puts
            puts "DatabaseModel Fatal Error in SentFile::setBeenSent ! :-("
            puts "hParams must be a Hash instance"
            puts
            exit(99)
         end

         exampleFile = SentFile.new
         arrAttrs    = exampleFile.attribute_names

         hParams.each_key{|aKey|
            if arrAttrs.include?(aKey.downcase) == false then
               puts "#{aKey.downcase} is not field of SENT_FILES table"
               puts
               exit(99)            
            end
         }
      end

      someFiles = SentFile.find_all_by_filename(file)
      
      if someFiles != nil then
         someFiles.each{|aFile|
#             puts interface.name
#             puts aFile.interface
#             puts aFile.filename
#             puts aFile.delivery_date

            if aFile.interface == nil then
               aFile.interface = interface.name
#                intFace = Interface.new
#                intFace.name = interface.name
#                intFace.save!
#                aFile.interface = intFace
#                aFile.save!
            end

            if aFile.interface == interface.name then
               methods = aFile.delivered_using
               if methods == nil then
                  methods = ""
               end
               if methods.include?(deliveryMethod) == false then
                  methods = %Q{#{methods}#{deliveryMethod};}
               end
               aFile.delivered_using = methods
               aFile.delivery_date   = Time.now
               # Update all optional params in the database
               if hParams != nil then
                  hParams.each_pair{|key,value|
                     aFile.update_attribute(key.downcase, value)
                  }
               end
               aFile.save!
               return
            end
         }
      end

      sentFile                   = SentFile.new
      sentFile.filename          = file
      sentFile.interface_id      = interface.id
      sentFile.delivered_using   = %Q{#{deliveryMethod};}
      sentFile.delivery_date     = Time.now
      if hParams != nil then
         # Update all optional params in the database
         hParams.each_pair{|key,value|
            sentFile.update_attribute(key.downcase, value)
         }
      end
      sentFile.save!
   end
   #-----------------------------------------------------------

end
#=====================================================================



#-----------------------------------------------------------
# RPF "Legacy" Tables


#=====================================================================

class InventoryFile < ActiveRecord::Base
   self.table_name   = 'FILE_TB'
   self.primary_key  = 'FILE_ID'
end
#=====================================================================

class InventoryROPFile < ActiveRecord::Base
   self.table_name = 'FILE_ROP_TB'
   # set_primary_key 'ROP_ID', 'FILE_ID'
end
#=====================================================================

class InventoryROP < ActiveRecord::Base
   self.table_name   = 'ROP_TB'
   self.primary_key  = 'ROP_ID'
   
   # class constants
   TRANSFERABLE          = 0
   NOT_TRANSFERABLE      = 1
      
   STATUS_NEW            = 0
   STATUS_VALIDATED      = 1
   STATUS_CONSOLIDATED   = 2
   STATUS_TRANSFERRED    = 3
   STATUS_BEING_TRANSFERRED = 4

   #-----------------------------------------------------------
   # Set ROP Status
 
   def InventoryROP.setROPStatus(nROP, nStatus)
      aROP = InventoryROP.find_by_rop_id(nROP)
      if aROP == nil then
         return false
      end
      InventoryROP.update_all "status = #{nStatus}", "rop_id = #{nROP}"
      return true
   end
   #-----------------------------------------------------------

   def InventoryROP.setTransferred(nROP)
      InventoryROP.setROPStatus(nROP, STATUS_TRANSFERRED)
      InventoryROP.unsetAllTransferable(nROP)
   end
   #-----------------------------------------------------------
   # Unset transferable flagf for all ROPs except the given ROP 
   
   def InventoryROP.unsetAllTransferable(nROP)
      aROP = InventoryROP.find_by_rop_id(nROP)
      if aROP == nil then
         return false
      end
      InventoryROP.update_all "transferability = #{NOT_TRANSFERABLE}", "rop_id != #{nROP}"
      InventoryROP.update_all "transferability = #{TRANSFERABLE}", "rop_id = #{nROP}"
      return true
   end
   #-----------------------------------------------------------

end

#=====================================================================

class InventoryROPFileView < ActiveRecord::Base
   self.table_name = 'ROP_FILE_VW'
end
#=====================================================================

class InventoryParams < ActiveRecord::Base
   self.table_name   = 'PARAMETERS_TB'
   self.primary_key  = 'KEYWORD'
end
#=====================================================================



#-----------------------------------------------------------

