#!/usr/bin/env ruby


require 'rake'
require 'date'
require 'fileutils'

begin
   require 'cuc/CryptHelper'
rescue Exception 
   require_relative 'code/cuc/CryptHelper'
end

require_relative 'code/dec/DEC_Environment'

### ============================================================================
###
### Task associated to DEC component

namespace :dec do

   ## -----------------------------
   ## DEC Config files
   
   @arrConfigFiles = [\
      "dec_interfaces.xml",\
      "dec_incoming_files.xml",\
      "dec_outgoing_files.xml",\
      "ft_mail_config.xml",\
      "dec_log_config.xml",\
      "dec_config.xml"]
   ## -----------------------------
   
   @rootConf = "config/oper_dec"
   
   ### ====================================================================
   ###
   
   ## ----------------------------------------------------------------

   desc "fetch gem dependencies"

   task :fetchgems do
      prevDir  = Dir.pwd
      file     = File.open("gem_dec.gemspec")
      Dir.chdir("foss/gems")
      arrLines = file.readlines
      arrLines.each{|line|
         # gem fetch activerecord --version "=6.0" 
         if line.include?('dependency') then
            item     = line.split("\'")[1]
            version  = line.split("\'")[3]
            cmd = "gem fetch #{item} -v \"#{version}\""
            puts cmd
            system(cmd)
         end
      }
      Dir.chdir(prevDir)
   end

   ## ----------------------------------------------------------------

   desc "encrypt string"

   task :encryptstring, [:string] do |t, args|
      include CUC::CryptHelper
      plaintext = args[:string]
      puts "encrypt string: #{plaintext}"
      puts cmdEncryptStr(plaintext)
   end

   ## ----------------------------------------------------------------

   desc "decrypt string"

   task :decryptstring, [:string] do |t, args|
      include CUC::CryptHelper
      cryptedtext = args[:string]
      puts "decrypt string: #{cryptedtext}"
      puts cmdDecryptStr(cryptedtext)
   end

   ## ----------------------------------------------------------------

   desc "generate PDF documentation"

   task :gendoc do
      prevDir = Dir.pwd
      Dir.chdir("doc/tex")
      cmd = "xelatex -synctex=1 -interaction=nonstopmode \"dec_sum_main\".tex"
      puts cmd
      system(cmd)
      date     = DateTime.now
      filename = "DEC-SUM2025-E_#{date.strftime("%Y%m%d")}.pdf"
      
      begin
         FileUtils.rm filename
      rescue Exception
      end

      begin
         FileUtils.rm "../pdf/#{filename}"
      rescue Exception
      end

      cmd      = "ln dec_sum_main.pdf #{filename}"
      system(cmd)
      puts "Generated #{filename}"    
      FileUtils.mv(filename, "../pdf")
      FileUtils.mv("dec_sum_main.pdf", "../pdf")
      Dir.chdir(prevDir)
   end

   ## ----------------------------------------------------------------
   ### DEC Containerised tasks
   
   desc "build docker DEC image [user , host , prefix]"

   task :image_build, [:user, :host, :suffix] do |t, args|
      # args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2)
     
      dockerFile = "Dockerfile.#{args[:suffix]}.dec.#{args[:host]}.#{args[:user]}.yaml"
   
      puts "building Docker Image DEC with config #{args[:user]} #{args[:suffix]}@#{args[:host]}"
      puts "#{dockerFile}"

      if File.exist?("install/docker/#{dockerFile}") == false then
         puts "DEC Dockerfile #{dockerFile} not present in repository"
         exit(99)
      end
   
      cmd = "docker image build --rm=false -t app_#{args[:suffix]}_dec:latest . -f \"install/docker/#{dockerFile}\""
      puts cmd
      retval = system(cmd)
   end

   ## ----------------------------------------------------------------

   desc "build DEC gem & docker DEC image"

   task :image_build_all, [:user, :host, :suffix] => :build do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2)
      puts "building Docker Image DEC with config #{args[:user]} #{args[:suffix]}@#{args[:host]}"
   
      dockerFile = "Dockerfile.dec.#{args[:suffix]}.#{args[:host]}.#{args[:user]}"
   
      if File.exist?("install/docker/#{dockerFile}") == false then
         puts "DEC Dockerfile #{dockerFile} not present in repository"
         exit(99)
      end
   
      cmd = "docker image build --rm=false -t app_dec_#{args[:suffix]}:latest . -f \"install/docker/#{dockerFile}\""
      puts cmd
      retval = system(cmd)
   end

   ## ----------------------------------------------------------------
   
   desc "podman init"
   task :podman_init do
      puts "starting podman qemu environment"

      cmd = "podman machine stop"
      puts
      puts cmd
      puts
      system(cmd)

      cmd = "podman machine rm"
      puts
      puts cmd
      puts
      system(cmd)

      cmd = "podman machine init --volume=/data:/data --timezone Europe/London"
      puts
      puts cmd
      puts
      system(cmd)

      cmd = "podman machine start"
      puts
      puts cmd
      puts
      system(cmd)
   end

   ## ----------------------------------------------------------------

   # https://docs.podman.io/en/latest/markdown/podman-load.1.html
   # https://docs.podman.io/en/latest/markdown/podman-create.1.html
   # https://docs.podman.io/en/latest/markdown/podman-run.1.html
   # https://www.tutorialworks.com/podman-host-networking/

   desc "podman run"

   task :podman_run, [:image_file] do |t, args|
      img = args[:image_file]
      puts "executing Docker Container DEC with config #{img}"
   
      if img.include?(".7z") == true then
         cmd = "7za x #{img}"
         puts cmd
         retval = system(cmd)
         img = img.dup.gsub("7z", "tar")
      end

      cmd = "podman container stop dec"
      puts cmd
      retval = system(cmd)

      cmd = "podman container rm dec"
      puts cmd
      retval = system(cmd)      

      cmd = "podman load -i #{img}"
      puts cmd
      retval = system(cmd)

      # cmd = "podman run --name dec -d --mount type=bind,source=/data,destination=/data localhost/dec_naos_gsc4eo_nl2-s-aut-srv-01:latest"
      cmd = "podman run --userns keep-id --env 'USER' --add-host=nl2-s-aut-srv-01:192.168.1.24 --network=host --tz=Europe/London --name dec -d --mount type=bind,source=/data,destination=/data localhost/dec_naos-test_gsc4eo_nl2-u-moc-srv-01:latest"
      cmd = "podman run --userns keep-id --env 'USER' --add-host=nl2-s-aut-srv-01:192.168.1.24 --network=host --tz=Europe/London --name dec -d --mount type=bind,source=/data,destination=/data localhost/dec_naos_gsc4eo_nl2-u-moc-srv-01:latest"
      puts cmd
      retval = system(cmd)

   end
   ## ----------------------------------------------------------------

   # https://docs.podman.io/en/latest/markdown/podman-machine-init.1.html
   # https://docs.podman.io/en/latest/markdown/podman-build.1.html
   # https://docs.podman.io/en/latest/markdown/podman-save.1.html

   # podman build -f Containerfile.simple .
   desc "podman build"

   task :podman_build, [:user, :host, :suffix] do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2)
      version = DEC.class_variable_get(:@@version)
      puts "building Docker Container DEC #{version} with config #{args[:user]} #{args[:suffix]}@#{args[:host]}"
   
      # Invoke the gem build task 
      Rake::Task['dec:build'].invoke(args[:user], args[:host], args[:suffix])

      ## dec-1.0.37c_naos_test_gsc4eo@nl2-u-moc-srv-01.gem

      dockerFile  = "dec_#{args[:suffix]}_#{args[:user]}@#{args[:host]}.dockerfile"
      imgFile     = "dec-#{version}_#{args[:suffix]}_#{args[:user]}@#{args[:host]}"
      imgName     = "dec_#{args[:suffix]}_#{args[:user]}_#{args[:host]}"

      if File.exist?("install/docker/#{dockerFile}") == false then
         puts "DEC Dockerfile #{dockerFile} not present in repository"
         exit(99)
      end

      cmd = "podman build --format docker -f \"install/docker/#{dockerFile}\" -t #{imgName} ."
      puts
      puts cmd
      puts
      retval = system(cmd)

      cmd = "podman save -o #{imgFile}.tar #{imgName}"
      puts
      puts cmd
      puts
      retval = system(cmd)

      cmd = "7za a -t7z #{imgFile}.7z #{imgFile}.tar -mx=7"
      puts cmd
      retval = system(cmd)

      cmd = "rm -f #{imgFile}.tar"
      puts cmd
      retval = system(cmd) 

      cmd = "md5sum #{imgFile}.7z"
      ret = `#{cmd}`
      cmd = "echo #{ret.split(" ")[0]} > #{imgFile}.7z.md5"
      puts cmd
      system(cmd)

   end

   ## ----------------------------------------------------------------

   desc "build DEC gem & docker image (container)"

   task :container_build, [:user, :host, :suffix] do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2)
      puts "building Docker Container DEC with config #{args[:user]} #{args[:suffix]}@#{args[:host]}"
   
      dockerFile = "Dockerfile.dec.#{args[:suffix]}.#{args[:host]}.#{args[:user]}"
   
      if File.exist?("install/docker/#{dockerFile}") == false then
         puts "DEC Dockerfile #{dockerFile} not present in repository"
         exit(99)
      end
   
      cmd = "docker create --name dec_#{args[:suffix]} . -f \"install/docker/#{dockerFile}\""
      puts cmd
      retval = system(cmd)
   end
   
   ## ----------------------------------------------------------------

   desc "run DEC container"

   task :container_run, [:user, :host, :suffix] do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2)
      puts "Executing Docker Container DEC with config #{args[:user]} #{args[:suffix]}@#{args[:host]}"
      cmd = "docker container rm dec_#{args[:suffix]}"
      puts cmd
      system(cmd)
      cmd = "docker container run -dit --restart always --name dec_#{args[:suffix]} --hostname dec_#{args[:suffix]} --mount source=volume_dec,target=/volumes/dec --init  app_dec_#{args[:suffix]}:latest"
      puts cmd
      retval = system(cmd)
   end

   ## ----------------------------------------------------------------

   desc "shell to DEC container"

   task :container_shell, [:user, :host, :suffix] do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2)
      puts "Getting shell to Docker Container DEC with config #{args[:user]} #{args[:suffix]}@#{args[:host]}"      
      cmd = "docker container exec -i -t dec_#{args[:suffix]} /bin/bash"
      puts cmd
      retval = system(cmd)
   end

   ## ----------------------------------------------------------------

   ### ====================================================================
   ###
   ### DEC GEM Management tasks
   
   ## ----------------------------------------------------------------
   
   desc "build DEC gem [user, host, suffix = s2 | s2odata]"

   task :build, [:user, :host, :suffix] => :load_config do |t, args|
      args.with_defaults(:user => "dectest", :host => "localhost", :suffix => "s2_test_odata")
      puts "building gem dec #{args[:suffix]} with config #{args[:user]}@#{args[:host]}"
   
      if File.exist?("#{@rootConf}/#{args[:user]}@#{args[:host]}") == false then
         puts "DEC configuration not present in repository"
         exit(99)
      end
   
      ## -------------------------------
      
      Rake::Task["dec:update_manpages"].invoke
   
      ## -------------------------------
      ##
      ## Build flags
      ##
      if args[:suffix].include?("odata") == true then
         puts "building gem dec #{args[:suffix]} with flag DEC_ODATA"
         ENV['DEC_ODATA'] = "true"
      else
         ENV.delete('DEC_ODATA')
      end

      # specific mission flag

      puts "FLAGS:"
      puts args[:suffix].downcase

      if args[:suffix].downcase.include?("naos") == true then
         puts "building gem dec #{args[:suffix]} with flag DEC_ODATA"
         ENV['DEC_NAOS']       = "true"
      end

      if args[:suffix].downcase.include?("adgs") == true or args[:user].downcase.include?("adgs") == true then
         puts "building gem dec #{args[:suffix]} with flag DEC_ODATA"
         ENV['DEC_ADGS']       = "true"
      end

      if args[:suffix].downcase.include?("s2") == true then
         puts "building gem dec #{args[:suffix]} with flag DEC_SENTINEL2"
         ENV['DEC_SENTINEL2']  = "true"
      end

      if args[:suffix].include?("test") == true then
         puts "building gem dec #{args[:suffix]} with flag DEC_TEST"
         ENV['DEC_TEST'] = "true"
      else
         puts "building gem dec #{args[:suffix]}  ** without ** unit tests"
         ENV.delete('DEC_TEST')
      end
      
      if args[:suffix].include?("pg") == true then
         puts "building gem dec #{args[:suffix]} with flag DEC_PG"
         ENV['DEC_PG'] = "true"
      else
         puts "discarding pg gem"
         ENV.delete('DEC_PG')
      end
            
      ## -------------------------------
   
      cmd = "gem build gem_dec.gemspec"
      puts cmd
      ret = `#{cmd}`
      if $? != 0 then
         puts "Failed to build gem for DEC"
         exit(99)
      end
      filename = ret.split("File: ")[1].chop
      name     = File.basename(filename, ".*")
      mv filename, "#{name}_#{args[:suffix]}_#{args[:user]}@#{args[:host]}.gem"
      @filename = "#{name}_#{args[:suffix]}_#{args[:user]}@#{args[:host]}.gem"
      cp @filename, "install/gems/dec_#{args[:suffix]}.gem"
      cp @filename, "install/gems/"
      begin
         rm "install/gems/dec_latest.gem"
      rescue Exception => e
         puts e.to_s
      end
      puts "ln #{@filename} install/gems/dec_latest.gem"
      ln @filename, "install/gems/dec_latest.gem"

      cmd = "md5sum #{@filename}"
      ret = `#{cmd}`
      cmd = "echo #{ret.split(" ")[0]} > #{@filename}.md5"
      puts cmd
      system(cmd)
      begin
         File.unlink("install/gems/dec_latest.gem.md5")
      rescue Exception => e
         puts e.to_s
      end
      ln "#{@filename}.md5", "install/gems/dec_latest.gem.md5"
      # rm @filename
   end

   ## ----------------------------------------------------------------

   desc "list DEC configuration packages"

   task :list_config do
      cmd = "ls #{@rootConf}"
      system(cmd)
   end
   
   ## ----------------------------------------------------------------
   
   desc "update man pages"

   task :update_manpages do
      cmd = "ronn man/dec.1.ronn"
      puts cmd
      system(cmd)

      cmd = "ronn man/decODataClient.1.ronn"
      puts cmd
      system(cmd)
      
   end   
   ## ----------------------------------------------------------------
   
   desc "check DEC configuration package"
   
   task :check_config, [:user, :host] do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost)
      
      if File.exist?("#{@rootConf}/#{args[:user]}@#{args[:host]}") == false then
         puts "DEC configuration not present in repository"
         exit(99)
      end
      
      path     = "#{@rootConf}/#{args[:user]}@#{args[:host]}"
      prefix   = "#{args[:user]}@#{args[:host]}#"
      
      @arrConfigFiles.each{|file|
         filename = "#{path}/#{prefix}#{file}"
         if File.exist?(filename) == false then
            puts "#{filename} not found :-("
         else
            puts "#{filename} is present :-)"
         end
      }
      
   end
   ## ----------------------------------------------------------------

   desc "save DEC configuration package"

   task :save_config, [:user, :host] do |t, args|
      args.with_defaults(:user => :new_config_saved, :host => :localhost)
            
      path     = "#{@rootConf}/#{args[:user]}@#{args[:host]}"
      
      if File.exist?(path) == false then
         mkdir_p path
      else
         puts
         puts "THINK CAREFULLY !"
         puts
         puts "this will overwrite configuration for #{args[:user]}@#{args[:host]}"
         puts
         puts "proceed? Y/n"
               
         c = STDIN.getc   
         if c != 'Y' then
            exit(99)
         end
      end
      
      prefix   = "#{args[:user]}@#{args[:host]}#"
      
      @arrConfigFiles.each{|file|
         cp "config/#{file}", filename = "#{path}/#{prefix}#{file}"
      }
   end
   ## --------------------------------------------------------------------

   ## --------------------------------------------------------------------

   desc "load DEC configuration package"

   task :load_config, [:user, :host, :suffix] do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => "s2_test_pg_odata")
      puts "loading configuration for #{args[:user]}@#{args[:host]} for #{args[:suffix]}"      
      path     = "#{@rootConf}/#{args[:user]}@#{args[:host]}"
      
      if File.exist?(path) == false then
         mkdir_p path
      end
      
      prefix   = "#{args[:user]}@#{args[:host]}#"
      
      @arrConfigFiles.each{|file|
         filename = "#{path}/#{prefix}#{file}"
         if File.exist?(filename) == true then
            cp filename, "config/#{file}"
         else
            puts "#{filename} not found #{'1F480'.hex.chr('UTF-8')}"
            exit(99)
         end
      }
   end
   ## ----------------------------------------------------------------
   
   desc "uninstall DEC gem"
   
   task :uninstall do
      cmd = "gem uninstall -x dec"
      puts cmd
      system(cmd)      
   end
   ## ----------------------------------------------------------------

   desc "install DEC"

   task :install ,[:user, :host, :suffix] => :build do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2_pg)
      puts
      puts @filename
      puts
      
      Rake::Task["dec:uninstall"].invoke
#      cmd = "gem uninstall -x dec"
#      puts cmd
#      system(cmd)
      
      cmd = "gem install #{@filename} --no-document"
      puts cmd
      system(cmd)
      rm @filename
   end
   ## --------------------------------------------------------------------

   desc "Start DEC with docker compose"

   task :start, [:user, :host, :suffix] do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2)
      conf = "docker-compose.dec.#{args[:suffix]}.#{args[:host]}.#{args[:user]}.yml"
      cmd  = "docker-compose -f install/docker/#{conf} up -d"
      puts cmd
      system(cmd)
   end

   ## --------------------------------------------------------------------

   desc "Stop DEC with docker compose"

   task :stop, [:user, :host, :suffix] do |t, args|
      args.with_defaults(:user => :dectest, :host => :localhost, :suffix => :s2)
      conf = "docker-compose.dec.#{args[:suffix]}.#{args[:host]}.#{args[:user]}.yml"
      cmd  = "docker-compose -f install/docker/#{conf} down"
      puts cmd
      system(cmd)
   end


   ## --------------------------------------------------------------------

   ## Use this task to maintain an index of the relevant configurations
   ##
   desc "help in the kitchen"

   task :help do
      puts "The kitchen supports the following parameters"
      puts "user => used to define the node" 
      puts "host => used to define the node"
      puts "suffix: odata | test | pg"
      puts
      puts "Some of the above flags can be combined:"
      puts
      puts "> odata : it ships only the decODataClient"
      puts "> test  : it ships the DEC test tools"
      puts "> pg    : it includes installation requirement for postgresql gem"
      puts
      puts
      puts "Most used recipes:" 
      puts
      puts "== PODMAN INIT =="
      puts "rake -f build_dec.rake dec:podman_init"
      puts
      puts "== PODMAN RECIPEES =="
      puts "rake -f build_dec.rake dec:podman_build[gsc4eo,nl2-u-moc-srv-01,naos-test]"
      puts "rake -f build_dec.rake dec:podman_build[gsc4eo,nl2-s-aut-srv-01,naos-test]"
      puts "rake -f build_dec.rake dec:podman_build[gsc4eo,nl2-s-aut-srv-01,naos]"
      puts 
      puts "DEC Unit Tests"
      puts "rake -f build_dec.rake dec:install[dectest,localhost,s2_test_pg_odata]"
      puts "rake -f build_dec.rake dec:install[dectest,localhost,s2_test_pg]"
      puts
      puts "S2PDGSENG / Inputhub"
      puts "pull VPMC & VPMC_TCI or SVPMC & SVPMC_TCI"
      puts "push HTTP_FERRO"
      puts "rake -f build_dec.rake dec:build[push_lisboa,e2espm-inputhub,s2]"
      puts
      puts "CloudFerro / S2BOA"
      puts "pull LISBOA"
      puts "pull LOCALFERRO"
      puts "rake -f build_dec.rake dec:build[dec,s2boa-cloudferro,s2]"      
      puts
      puts "NAOS / NAOS-MOC-SERVER (UAP)"
      puts "pull CELESTRAK_SFS, CELESTRAK_TLE, CELESTRAK_TCA, NASA_NBULA, NASA_NBULC, NASA_SFL"
      puts "push TBD"
      puts "rake -f build_dec.rake dec:build[gsc4eo,nl2-u-moc-srv-01,naos-test]"
      puts "rake -f build_dec.rake dec:install[gsc4eo,nl2-u-moc-srv-01,naos-test]"
      puts
      puts "NAOS / NAOS-AUTO (SAP)"
      puts "rake -f build_dec.rake dec:build[gsc4eo,nl2-s-aut-srv-01,naos-test]"
      puts "rake -f build_dec.rake dec:install[gsc4eo,nl2-s-aut-srv-01,naos-test]"
      puts "pull SIM_DDC_ADA, SIM_DDC_TLM, SIM_KSAT_ADA, SIM_KSAT_TLM"
      puts      
      puts "NAOS / NAOS-MCS-IVV"
      puts "pull NAOS_MCS_SFTP"
      puts "push NAOS_MCS_SFTP"
      puts "rake -f build_dec.rake dec:build[aiv,naos-aiv,naos]"
      puts
      puts "ADGS"
      puts "rake -f build_dec.rake dec:build[adgs,localhost,adgs_test_pg]"
      puts "rake -f build_dec.rake dec:install[adgs,localhost,adgs_test_pg]"
      puts                  
      puts "Obsolete:"
      puts "rake -f build_dec.rake dec:build[s2decservice,e2espm-inputhub,s2_pg]"
      puts "Pending ftp port management within containers:"
      puts "rake -f build_dec.rake dec:build[s2decservice_vpmc,e2espm-inputhub,s2]"


   end
   ## --------------------------------------------------------------------

   ## --------------------------------------------------------------------

   desc "perform RSpec TDD/BDD"

   task :test_rspec do
      cmd = "rspec -fd --profile --default-path code/dec"
      puts cmd
      ret = system(cmd)

      if ret != true then
         puts "Failed to execute rspec for DEC"
         exit(99)
      end
   end
   ## --------------------------------------------------------------------

end
## =============================================================================



## =============================================================================

task :default do
   puts "DEC repository management"
   cmd = "rake -f build_dec.rake -T"
   system(cmd)
end

## =============================================================================

