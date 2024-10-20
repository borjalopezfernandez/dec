#!/usr/bin/env ruby

## http://morningcoffee.io/interfaces-in-ruby.html

module DEC

require 'dec/ReadConfigDEC'

class InterfaceHandlerAbstract

   ## -----------------------------------------------------------
   ##
   ## Class constructor.
   ## * entity (IN):  Entity textual name (i.e. FOS)
   def initialize(entity, log, bDCC=true, bDDC=true, manageDirs=false)
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end   
   ## -----------------------------------------------------------
   ##
   ## Set the flag for debugging on
   def setDebugMode
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end
   ## -----------------------------------------------------------

   ## -----------------------------------------------------------
   ## DEC - Pull

   def getPullList
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end

   ## -----------------------------------------------------------
   ## to inspect object

   def to_s
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end
   ## -----------------------------------------------------------

   def checkConfig(entity, pull, push)
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end
   ## -----------------------------------------------------------

   def pushFile(sourceFile, targetFile, targetTemp)
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end
   ## -----------------------------------------------------------
   
   def getUploadDirList(bTemp = false)
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end
   ## -----------------------------------------------------------

   def checkRemoteDirectory(directory)
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end
   ## -----------------------------------------------------------

   def getDirList(directory)
      raise NotImplementedError.new("#{self.class}::#{__method__.to_s} needs to be implemented")
   end
   ## -----------------------------------------------------------
   
   ## We are placed on the right directory (tmp dir): 
   ##          receiveAllFiles->downloadFile->self
   
   ## Download a file from the I/F
   def downloadFile(filename)
      raise NotImplementedError.new("#{__method__.to_s} needs to be implemented")
   end	
	## -----------------------------------------------------------

   ## Download a file from the I/F
   def downloadDir(directory)      
      raise NotImplementedError.new("#{__method__.to_s} needs to be implemented")
	end
   ## -----------------------------------------------------------

   ## Download a file from the I/F
   def deleteFromEntity(filename)      
      raise NotImplementedError.new("#{__method__.to_s} needs to be implemented")
	end

   ## -------------------------------------------------------------

end # class

end # module
