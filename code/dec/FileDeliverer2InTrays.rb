#!/usr/bin/env ruby

require 'fileutils'

require 'cuc/Log4rLoggerFactory'
require 'cuc/CommandLauncher'
require 'cuc/DirUtils'
require 'cuc/PackageUtils'
require 'cuc/EE_ReadFileName'
require 'dec/ReadConfigDEC'
require 'dec/ReadInterfaceConfig'
require 'dec/ReadConfigIncoming'
require 'dec/EventManager'

 # This class moves all files from the I/Fs local inboxes
 # to the configured In-Trays

module DEC

class FileDeliverer2InTrays

   include CUC::DirUtils
   include CUC::CommandLauncher
   include CUC::PackageUtils

   ## -------------------------------------------------------------

   ## Class contructor
   ##
   def initialize(debugMode = false)
      @@isModuleOK         = false
      @@isModuleChecked    = false
      @isDebugMode         = debugMode
      checkModuleIntegrity

      # -------------------------------
      # initialize logger
      loggerFactory = CUC::Log4rLoggerFactory.new("pull", "#{@@configDirectory}/dec_log_config.xml")
      if @isDebugMode then
         loggerFactory.setDebugMode
      end
      @logger = loggerFactory.getLogger
      if @logger == nil then
         puts
			puts "Error in FileDeliverer2InTrays::initialize"
			puts "Could not set up logging system !  :-("
         puts "Check DEC logs configuration under \"#{@@configDirectory}/dec_log_config.xml\""
			puts
			puts
			exit(99)
      end
      # -------------------------------
      @entConfig           = ReadInterfaceConfig.instance
      ReadConfigIncoming.logger = @logger
		@dimConfig           = ReadConfigIncoming.instance
      if @isDebugMode == true then
         @dimConfig.setDebugMode
      end
      @entity              = "not initialised"

      # Not used by this class at the time being
      # @satPrefix = DEC::ReadConfigDEC.instance.getSatPrefix

      @tmpDir = DEC::ReadConfigDEC.instance.getTempDir

   end
   ## -----------------------------------------------------------

   ## Set the flag for debugging on.
   def setDebugMode
      @isDebugMode = true
      @logger.debug("FileDeliverer2InTrays debug mode is on")
	   @entConfig.setDebugMode
		@dimConfig.setDebugMode
   end
   ## -----------------------------------------------------------

   ## Main method of the class which delivers the incoming files
   ## from the local Entities In-Boxes to the DIMs In-Trays
   def deliver(mnemonic = "")
      @entity = mnemonic
#	   setDebugMode

      if mnemonic != "" and @isDebugMode == true then
         @logger.debug("Dissemination of files previously received from #{mnemonic}")
      end

      arrEnts   = @entConfig.getAllExternalMnemonics

		arrEnts.each{|entity|

         if mnemonic != "" and entity.to_s != mnemonic then
            next
         end

         dir = @dimConfig.getIncomingDir(entity)

         if @isDebugMode == true then
            @logger.debug("#{entity} local inbox #{dir}")
         end

			arrFiles = getFilenamesFromDir(dir, "*")
			if arrFiles.empty? == true then
			   if @isDebugMode == true then
				   @logger.debug("There are no previous files to disseminate")
				end
            next
			end

			arrFiles.each{|afile|

            file = File.basename(afile)

            bIsEEFile   = CUC::EE_ReadFileName.new(file).isEarthExplorerFile?
            fileType    = CUC::EE_ReadFileName.new(file).fileType
            dimsDirs    = Array.new
            dimsName    = Array.new
            bByType     = true

            if bIsEEFile == true then
               bByType  = true
               dimsDirs = @dimConfig.getTargetDirs4Filetype(fileType)
               dimsName = @dimConfig.getDIMs4Filetype(fileType)
		      else
               bByType  = false
               dimsDirs = @dimConfig.getTargetDirs4Filename(file)
               dimsName = @dimConfig.getDIMs4Filename(file)
            end

            if dimsName != false then
               if @isDebugMode == true then
                  dimsName.each{|dim|
                     @logger.debug("#{file} is disseminated to #{dim}")
                  }
               end
            else
               # @logger.warn("#{file} has no InTray config")
               if @isDebugMode == true then
                  @logger.debug("#{file} has no InTray config")
               end
            end


            if dimsDirs.empty? == false then

				   hdlinked = ""

               if bByType == true then
                  hdlinked = @dimConfig.isHardLinked?(fileType)
	            else
                  hdlinked = @dimConfig.isHardLinked?(file)
               end

               if @isDebugMode == true then
					   @logger.debug("CONTROL-1 #{file} is disseminated to: #{dimsName}")
					end

               # main dissemination method
               # - interface
               # - file
               # - from directory
               # - to array of directories

               # ret = disseminate(entity, file, dir, dimsDirs, hdlinked)

					ret = disseminate(entity, file, dir, dimsName, hdlinked)

#               ## ---------------------------------
#               # 20170601 - Patch to compress locally disseminated files
#               if ret == true then
#                  ret = compressFile(dimsName, file)
#               end
#               ## ---------------------------------

               ## ---------------------------------

               # The original file is only deleted if the dissemination has been
               # performed successfully, otherwise it is kept in order to not loose
               # the information and perform a later manual dissemination
               if ret == true then
                  begin
                     if @isDebugMode == true then
                        @logger.debug("[DEC_951.2] I/F #{mnemonic}: Removing #{dir}/#{file}")
                        @logger.debug("#{file} has been disseminated locally according to rules")
                     end
                     FileUtils.rm_f("#{dir}/#{file}")
                  rescue Exception
                     @logger.error("Could not delete #{dir}/#{file}")
                     exit(99)
                  end
               else
                  # @logger.error("#{file} has not been disseminated")
                  @logger.warn("[DEC_331] I/F #{entity}: #{file} is stuck in LocalInbox #{dir}")
               end
				end
			}
      }

   end
   ## -----------------------------------------------------------

   ## It Deliver Files present in a given directory
   def deliverFromDirectory(directory)
         arrFiles = getFilenamesFromDir(directory, "*")
			if arrFiles.empty? == true then
			   if @isDebugMode == true then
               logger.debug("deliverFromDirectory: there are no new files to disseminate")
				end
			end

         arrFiles.each{|file|
            deliverFile(nil, directory, file)
			}
   end
   ## -------------------------------------------------------------

   ## It delivers a given file
   def deliverFile(entity, directory, afile)
      @entity  = entity
      file     = File.basename(afile)

#      @logger.info("deliverFile directory => #{directory}")
#      @logger.info("deliverFile file => #{file}")

      bByType  = false
      dimsDirs = @dimConfig.getTargetDirs4Filename(file)
      dimsName = @dimConfig.getDIMs4Filename(file)

      if dimsName != false then
         if @isDebugMode == true then
            dimsName.each{|dim|
               @logger.debug("#{file} is disseminated to #{dim}")
            }
         end
      else
         # @logger.warn("#{file} has no InTray config")
         if @isDebugMode == true then
            @logger.debug("#{file} has no InTray config")
         end
      end

      if dimsDirs.empty? == false then
	      hdlinked = false

         if bByType == true then
            hdlinked = @dimConfig.isHardLinked?(fileType)
	      else
            hdlinked = @dimConfig.isHardLinked?(file)
         end

         if @isDebugMode == true then
			   @logger.debug("#{file} is disseminated in: #{dimsDirs}")
		   end

         dimsDirs.each{|dir|
            if @isDebugMode == true then
               @logger.debug("checkDirectory => #{dir}")
            end
            checkDirectory(dir)
         }

#         disseminate(file, directory, dimsDirs, hdlinked)
#         File.delete("#{directory}/#{file}")


         ## 20200324

 		   # ret = disseminate(entity, file, directory, dimsDirs, hdlinked)

         # @logger.debug("BEFORE DISSEMINATE #{file}")


         if file.include?("&") == true and file.include?("\"") == false then
            file = %Q{\"#{file.dup}\"}
            if @isDebugMode == true then
               @logger.debug("filename is double quoted into #{file}")
            end
         end


         if @isDebugMode == true then
            @logger.debug("disseminate(#{file})")
         end

         ret = disseminate(entity, file, directory, dimsName, hdlinked)

         # @logger.debug("AFTER DISSEMINATE #{ret}")

#         # ---------------------------------
#         # 20170601 - Patch to compress locally disseminated files
#
#         if ret == true then
#            ret = compressFile(dimsName, file)
#         end
#
#         # ---------------------------------


         # The original file is only deleted if the dissemination has been
         # performed successfully, otherwise it is kept in order to not loose
         # the information and perform a later manual dissemination
         if ret == true then
            begin
               if @isDebugMode == true then
                  @logger.debug("[DEC_951_1] I/F #{entity}: Removing #{directory}/#{file}")
               end
               cmd = "rm -f #{directory}/#{file}"
               if @isDebugMode == true then
                  @logger.debug(cmd)
               end
               ret = system(cmd)
               # FileUtils.rm_f("#{directory}/#{file}")

               if ret == false then
                  @logger.error("FAILED #{cmd}")
               end

               if @isDebugMode == true then
                  @logger.debug("File #{file} has been disseminated locally according to rules")
               end
            rescue Exception
               @logger.error("dissemination : Could not delete #{file}")
               exit(99)
            end
         else
            @logger.warn("[DEC_331] I/F #{entity}: #{file} is stuck in #{directory} directory")
         end
      else
         if @isDebugMode == true then
            @logger.debug("#{file} is not disseminated to any Intray")
            @logger.debug("#{file} is still placed in #{directory}")
         end
      end
   end
   ## -----------------------------------------------------------

private

   @@isModuleOK        = false
   @@isModuleChecked   = false
   @isDebugMode        = false
   @@configDirectory   = ""
   @@monitorCfgFiles   = nil
   @@arrExtEntities    = nil

   ## -----------------------------------------------------------

   # Check that everything needed by the class is present.
   def checkModuleIntegrity
      bDefined = true
      bCheckOK = true

      if !ENV['DCC_CONFIG'] and !ENV['DEC_CONFIG'] then
         puts "DEC_CONFIG environment variable not defined !  :-(\n"
         bCheckOK = false
         bDefined = false
      end

      configDir = nil

      if ENV['DEC_CONFIG'] then
         configDir         = %Q{#{ENV['DEC_CONFIG']}}
      else
         configDir         = %Q{#{ENV['DCC_CONFIG']}}
      end

      @@configDirectory = configDir

      if bCheckOK == false then
         puts "FileDeliverer2InTrays::checkModuleIntegrity FAILED !\n\n"
         exit(99)
      end
   end
   ## -----------------------------------------------------------
	##
   ## It disseminates the file from a directory to a set of target dirs.
   ## GOCEPMF-SPR-005
   ## First at all it copies the file hidden in the In-Tray
   ## Once it has been completely copied, it renames it to the operational name

   ## 20200325 - change function signature to include the Intray names
   ## > get directory
   ## > get execution command

   def disseminate(entity, afile, fromDir, arrToIntray, hardlinked = false)

      bCompressAny   = false
      bUnCompressAny = false
      bReturn        = true
		prevDir        = Dir.pwd
      file           = File.basename(afile)
		bFirst         = true
      cmd            = ""

=begin
      if file.include?("&") == true and file.include?("\"") == false then
         file = %Q{\"#{file.dup}\"}
         if @isDebugMode == true then
            @logger.debug("file has been double quoted: #{file}")
         end
      end
=end

		Dir.chdir(fromDir)

      if @dimConfig.isCompressed?(arrToIntray) == true then
         bCompressAny = true
      end

      if @dimConfig.isUnCompressed?(arrToIntray) == true then
         bUnCompressAny = true
      end

      arrToIntray.each{|intray|
         ## ------------------------------------------------
         targetDir      = @dimConfig.getInTrayDir(intray)
         exec           = @dimConfig.getInTrayExecution(intray)
         checkDirectory(targetDir)
         compress  = @dimConfig.getInTrayCompress(intray)
         ## ------------------------------------------------
         ## Management of event NewFile2Intray
         hParams              = Hash.new
         hParams["filename"]  = file
         hParams["directory"] = targetDir
         ## ------------------------------------------------

         ## first file is firstly placed at @tmpDir

		   if bFirst == true then
			   bFirst   = false

            ## -----------------------------------
            ## Place the file in the @tmpDir
=begin
            if file.include?("?") == true then
               cmd  = "\\ln -f \"#{file}\" \"#{@tmpDir}/#{file}\""
            else
               cmd  = "\\ln -f #{file} #{@tmpDir}/#{file}"
            end
=end
            cmd  = "\\ln -f #{file} #{@tmpDir}/#{file}"

            if @isDebugMode == true then
               @logger.debug
            end

            bRet = execute(cmd, "pull")

            if @isDebugMode == true then
	   		   @logger.debug("[DEC_941.0] Intray #{intray}: Disseminate command (I) : #{cmd}")
		   	end

            if bRet == true then
               if @isDebugMode == true then
	   		      @logger.debug("[DEC_941.0] Success : #{cmd}")
		   	   end
            else
               @logger.error("[DEC_941.0] Failed #{cmd}")
            end

            ## -----------------------------------
            ## file is compressed at the @tmpDir directory
            if bCompressAny == true then
               compress7z(file)
            end

            ## -----------------------------------

            if compress == "7z" or compress == "7Z" then
               if @isDebugMode == true then
                  @logger.debug("Compress mode detected for #{intray}")
               end

               targetFile =  File.basename(file, ".*")
               targetFile = "#{targetFile}.7z"
               cmd = "\\ln -f #{@tmpDir}/7z/#{targetFile} #{targetDir}/#{targetFile}"
               bRet = execute(cmd, "pull")
               if bRet == true then
                  @logger.info("[DEC_115.2] Intray #{intray}: #{targetFile} disseminated into #{targetDir}")
               else
                  @logger.error("[DEC_626.1] Intray #{intray}: #{targetFile} failed dissemination into #{targetDir}")
               end
               next
            end
            ## -----------------------------------

            ## if file is to be decompressed
            if compress == "7z-x" or compress == "7Z-X" then
               if @isDebugMode == true then
                  @logger.debug("Decompress mode detected for #{intray}")
               end
               uncompress7z(file, fromDir, targetDir)
               next
            end

            ## -----------------------------------

            ### 20200316 UPDATE
            ### First operation is a hardlink to avoid copies
            # Move operation is not safe.
            # When dissemination is performed to several In-Trays, it is not
            # possible to rely on that a file would be still present in the first intray
            # a file is disseminated in.

            # --------------------------
            # Remove in target directory any eventual copy of a file with the same name
            if File.exist?(targetDir+'/'+file) then
               @logger.warn("[DEC_555_1] Intray #{intray}: #{file} duplicated already existed in #{targetDir}")
               @logger.warn("[DEC_556_1] Intray #{intray}: #{file} duplicated will be deleted before dissemination")
               FileUtils.rm_rf(targetDir+'/'+file)
            end
            # --------------------------

            # cmd  = "\\ln -f \"#{file}\" \"#{targetDir}/#{file}\""
            cmd  = "\\ln -f #{file} #{targetDir}/#{file}"

            if @isDebugMode == true then
               @logger.debug(cmd)
            end

            if @isDebugMode == true then
	   		   @logger.debug("[DEC_942.0] Intray #{intray}: Disseminate command (I) : #{cmd}")
		   	end
            bRet = execute(cmd, "pull")

            if bRet == false then
               @logger.error("[DEC_626.2] Intray #{intray}: #{file} failed dissemination into #{targetDir}")
               Dir.chdir(prevDir)
               bReturn = false
               return false
            end

            if bRet == false then
               @logger.error("FileDeliverer2InTrays::disseminate Could not place #{file} in Target Directory #{targetDir} ! :-(")
               bReturn = false
            else
               if @isDebugMode == true then
                  @logger.debug("chmod a=r #{targetDir}/#{file}")
               end

               cmd = "chmod a=r #{targetDir}/#{file}"
               if @isDebugMode == true then
                  @logger.debug(cmd)
               end
               ret = system(cmd)

               if ret == false then
                  @logger.error("FAILED #{cmd}")
               end

=begin
               begin
                  FileUtils.chmod "a=r", "\"#{targetDir}/#{file}\"" #, :verbose => true
               rescue Exception => e
                  @logger.error("Failed chmod a=r \"#{targetDir}#{file}\"")
                  @logger.error(e.to_s)
               end
=end

               @logger.info("[DEC_115.1] Intray #{intray}: #{file} disseminated into #{targetDir}")

               event  = EventManager.new

               # Execution before the event

               if exec != "" and exec != nil then
                  if @isDebugMode == true then
                     @logger.debug("#{intray} EVENT: #{exec}")
                  end
                  event.exec_trigger(intray, "NewFile2Intray", exec, hParams, @logger)
               end

               if @isDebugMode == true then
                  event.setDebugMode
               end

               if @isDebugMode == true then
                  @logger.debug("Event NEWFILE2INTRAY #{file} => #{targetDir}")
               end
               # @logger.info("Event NEWFILE2INTRAY #{file} => #{targetDir}")

               event.trigger(entity, "NEWFILE2INTRAY", hParams, @logger)

               # -------------------------------------------
            end

			   next

         end

         ## ------------------------------------------------

         ## if file is to be decompressed
         if compress == "7z-x" or compress == "7Z-X" then
            if @isDebugMode == true then
               @logger.debug("Decompress mode detected for #{intray}")
            end
            uncompress7z(file, fromDir, targetDir)
            next
         end

         fullTarget  = ""
         thecmd      = ""

         ## either link from @tmpDir or from LocalInbox

         ## ---------------------------------

         if compress == "7z" or compress == "7Z" then
            targetFile =  File.basename(file, ".*")
            targetFile = "#{targetFile}.7z"
            fullTarget = "#{targetDir}/#{targetFile}"
            thecmd = "\\ln -f #{@tmpDir}/7z/#{targetFile} #{fullTarget}"
         else
            targetFile = file
            fullTarget = "#{targetDir}/#{file}"
            if fullTarget.include?("?") == true then
               fullTarget = "\"#{fullTarget}\""
            end
            thecmd = "\\ln -f #{@tmpDir}/#{file} #{fullTarget}"
         end

         ## ---------------------------------
         ## Delete if the file previously exists in the target dir
         if File.exist?("#{fullTarget}") == true then
            cmd = "\\rm -f #{fullTarget}"
            @logger.warn("[DEC_555] Intray #{intray}: #{targetFile} duplicated already existed in #{fullTarget}")
            @logger.warn("[DEC_556] Intray #{intray}: #{targetFile} duplicated will be deleted before dissemination")
            execute(cmd, "pull")
         end
         ## ---------------------------------

         if @isDebugMode == true then
	         @logger.debug("[DEC_942.2] Intray #{intray}: Disseminate command : #{thecmd}")
		   end

         # ---------------------------------

         bRet = execute(thecmd, "pull")

         if bRet == false then
            @logger.error("[DEC_626.3] Intray #{intray}: #{targetFile} failed dissemination into #{targetDir}")
            bReturn = false
            next
         else
            @logger.info("[DEC_115.3] Intray #{intray}: #{targetFile} disseminated into #{targetDir}")
         end

         # ---------------------------------

         begin
            if @isDebugMode == true then
               @logger.debug("chmod a=r \"#{targetDir}/#{targetFile}\"")
            end
            cmd = "chmod a=r \"#{targetDir}/#{targetFile}\""
            ret = system(cmd)
            if ret == false then
               @logger.error(cmd)
            end
            # FileUtils.chmod "a=r", "\"#{targetDir}/#{targetFile}\"" #, :verbose => true
         rescue Exception => e
            @logger.error("Failed chmod a=r \"#{targetDir}/#{targetFile}\"")
            @logger.error(e.to_s)
         end

         # ---------------------------------

         event  = EventManager.new

         if @isDebugMode == true then
            event.setDebugMode
         end

         # Execution before the event

         if exec != "" and exec != nil then
            if @isDebugMode == true then
               @logger.debug("#{intray} EVENT: #{exec}")
            end
            event.exec_trigger(intray, "NewFile2Intray", exec, hParams, @logger)
         end

         #@logger.info("Event NEWFILE2INTRAY #{file} => #{targetDir}")

         if @isDebugMode == true then
            @logger.debug("Event NEWFILE2INTRAY #{file} => #{targetDir}")
         end

         event.trigger(@entity, "NEWFILE2INTRAY", hParams, @logger)


		}

		Dir.chdir(prevDir)

      if bReturn == true then
         begin
            if File.exist?("#{@tmpDir}/#{file}") == true then
               File.delete("#{@tmpDir}/#{file}")
            end
            if File.exist?("#{@tmpDir}/7z/#{File.basename(file, ".*")}.7z") == true then
               File.delete("#{@tmpDir}/7z/#{File.basename(file, ".*")}.7z")
            end
         rescue Exception => e
            @logger.error(e.to_s)
         end
      end

      return bReturn
   end
   ## ------------------------------------------------------

   def uncompress7z(file, fromDir, inTray)
      if @isDebugMode == true then
         @logger.debug("FileDeliverer2InTrays::uncompress7z(#{file})")
      end

      tmpsourceFile  = "#{fromDir}/#{file}"

      ## ----------------------------

      if File.exist?(tmpsourceFile) == false then
         @logger.error("missing #{tmpsourceFile}")
         @logger.error("skip decompression in 7z into #{inTray}")
         return false
      end

      ## ----------------------------

      ret = unpack7z(tmpsourceFile, inTray, false, @isDebugMode, @logger)

      if ret == false then
         @logger.error("[DEC_627] Could not uncompress in #{tmpsourceFile} into #{inTray}")
         retVal = false
      else
         msg = "[DEC_117] I/F #{@entity}: #{file} uncompressed in 7z at #{inTray}"
         @logger.info(msg)
      end

      ## ----------------------------

   end

   ## ------------------------------------------------------

   def compress7z(file)
      if @isDebugMode == true then
         @logger.debug("FileDeliverer2InTrays::compress(#{file})")
      end
      checkDirectory("#{@tmpDir}/7z")
      sourceFile     = file
      tmpsourceFile  = "#{@tmpDir}/7z/#{file}"
      targetFile     = File.basename(file, ".*")
      targetFile     = "#{targetFile}.7z"
      targetFile     = "#{@tmpDir}/7z/#{targetFile}"

      if File.exist?(sourceFile) == false then
         @logger.error("missing #{sourceFile}")
         @logger.error("skip compression in #{compress} to #{targetFile}")
      end

      cmd = "\\ln -f #{sourceFile} #{tmpsourceFile}"

      if @isDebugMode == true then
         @logger.debug(cmd)
      end

      ret = system(cmd)

      if ret == false then
         @logger.error("Could not copy in #{tmpsourceFile}")
         return false
      end

      ## ----------------------------

      ret = pack7z(tmpsourceFile, targetFile, true, @isDebugMode, @logger)

      if ret == false then
         @logger.error("Could not compress in 7z #{targetFile}")
         File.delete(targetFile)
         retVal = false
      else
         msg = "[DEC_116] I/F #{@entity}: #{file} compressed in 7z at with size #{File.size(targetFile)} bytes"
         @logger.info(msg)
      end

   end
   ## -----------------------------------------------------
   ##
   ## 20170601 Eventual compression upon local dissemination
   ##
   ##

   def compressFile(dimsName, file)
      retVal = true

      dimsName.each{|dim|

         inTray   = @dimConfig.getInTrayDir(dim)
         compress = @dimConfig.getInTrayCompress(dim)

         if compress == nil then
            if @isDebugMode == true then
               @logger.debug("No Compression #{dim} - #{file}")
            end
            next
         end

         sourceFile = "#{inTray}/#{file}"
         targetFile =  File.basename(file, ".*")
         targetFile = "#{targetFile}.7z"
         targetFile = "#{inTray}/#{targetFile}"

         if File.exist?(sourceFile) == false then
            @logger.error("missing #{sourceFile}")
            @logger.error("skip compression in #{compress} to #{targetFile}")
            retVal = false
            next
         end

         ## ----------------------------
         ## move the file to be compressed / uncompressed to TempDir
         cmd = "mv -f #{sourceFile} #{@tmpDir}"

         if @isDebugMode == true then
            @logger.debug(cmd)
         end
         ret = system(cmd)

         tmpsourceFile = ""
         if ret == true then
            tmpsourceFile = "#{@tmpDir}/#{file}"
         else
            @logger.error("Failed to mv prior compression => #{cmd}")
            @logger.error("#{file} compression skipped")
            next
         end
         ## ----------------------------

         bManaged = false

         ## ----------------------------
         if compress == "7z" then

            bManaged = true

            ret = pack7z(tmpsourceFile, targetFile, true, @isDebugMode, @logger)
            #ret = pack7z(sourceFile, targetFile, true, @isDebugMode, @logger)

            if ret == false then
               @logger.error("Could not compress in #{compress} #{targetFile}")
               File.delete(targetFile)
               retVal = false
            else
               msg = "[DEC_116] Intray #{dim}: #{file} compressed with size #{File.size(targetFile)} bytes in #{compress} at #{inTray}"
               @logger.info(msg)
            end
         end

         ## ----------------------------

         if compress == "7z-x" then

            bManaged = true

            ret = unpack7z(tmpsourceFile, inTray, true, @isDebugMode, @logger)
            # ret = unpack7z(sourceFile, true, @isDebugMode, @logger)

            if ret == false then
               @logger.error("[DEC_627] Intray #{dim}: Could not uncompress in #{compress} #{sourceFile}")

               ## Need to move the file elsewhere
               cmd = "mv -f #{sourceFile} #{@tmpDir}"
               if @isDebugMode == true then
                  @logger.debug(cmd)
               end
               ret = system(cmd)

               if ret == true then
                  @logger.warn("[DEC_XXX] Intray #{dim}: Moved #{File.basename(sourceFile,".*")} into #{@tmpDir}")
               else
                  @logger.error("[DEC_627BIS] Intray #{dim}: Failed to move #{sourceFile} into #{@tmpDir}")
                  @logger.error(cmd)
                  ## Block files in the interface LocalInbox to avoid loss of data
                  retVal = false
               end

            else
               msg = "[DEC_116] Intray #{dim}: #{file} uncompressed in #{compress} at #{inTray}"
               @logger.info(msg)
            end
         end

         if bManaged == false then
            @logger.error("Compression mode #{compress} not supported")
            retVal = false
         end

      }
      # -----------------------------------------------------
      return retVal
   end
   ## -------------------------------------------------------------

end # class

end # module
