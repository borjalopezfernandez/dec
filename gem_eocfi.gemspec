

require_relative 'code/eocfi/EOCFI_Environment'
include EOCFI

Gem::Specification.new do |s|
  s.name        = 'eocfi'
  s.version     = "#{EOCFI.class_variable_get(:@@version)}"
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.summary     = "EOCFI porting component"
  s.description = "Data Exchange Component"
  s.authors     = ["cf. Authors"]
  s.email       = 'mansobeach@gmail.com'
 
  ## --------------------------------------------
  ##
  ## platform
  if ENV.include?("EOCFI_PLATFORM") == false then
     ENV['EOCFI_PLATFORM'] = "MACIN64"
  end
  ## --------------------------------------------
 
  s.files       = Dir['config/eocfi_log_config.xml'] + \
                  Dir['code/cuc/*.rb'] + \
                  Dir['code/eocfi/data/*'] + \
                  Dir['code/eocfi/data/NS1_GSOV_MPL_GND_DB'] + \
                  Dir['code/eocfi/data/NS1_GSOV_MPL_ORBSCT'] + \
                  Dir['code/eocfi/data/S2A_GSOV_MPL_ORBSCT'] + \
#                  Dir['code/eocfi/ext/ruby_earth_explorer_cfi.bundle'] + \
                  Dir['code/eocfi/ext/*'] + \
                  Dir['code/eocfi/include/*.h'] + \
                  Dir['code/eocfi/EOCFI*.rb'] + \
                  Dir['code/eocfi/EOCFI_Constants.rb'] + \
                  Dir['code/eocfi/EOCFI_Environment.rb'] + \
                  Dir['code/eocfi/EOCFI_Loader_Wrapper_Earth_Explorer.rb'] + \
                  Dir['code/eocfi/eocfi_test_tools'] + \
                  Dir['code/eocfi/eocfi_test_wrapper_earth_explorer'] + \
                  Dir['code/eocfi/eocfi_test_wrapper_MA1'] + \
                  Dir['code/eocfi/eocfi_xvstation_vistime_compute'] + \
                  Dir['code/eocfi/explorer_orbit/data/*']

  s.extensions  = ['code/eocfi/ext/extconf_earth_explorer_cfi.rb']

  s.require_paths = [ 'code', 'code/eocfi' ]

  s.bindir        = [ 'code/eocfi' ]

  s.executables   = [ \
                      'eocfi_orbit', \
                      'eocfi_test_tools', \
                      'eocfi_xvstation_vistime_compute', \
                      'eocfi_test_wrapper_earth_explorer', \
                      'eocfi_test_wrapper_MA1' \
                     ]
  
  ## --------------------------------------------

  s.homepage    = 'https://github.com/borjalopezfernandez/dec'
  s.metadata    = { "source_code_uri" => "https://github.com/borjalopezfernandez/dec" }
    
  ## ----------------------------------------------
  
  s.required_ruby_version = '>= 2.7.0'
  
  ## ----------------------------------------------
  
  s.add_dependency('shell', '~> 0.8')
  
  s.add_development_dependency('rake-compiler', '~> 1') 
  s.add_development_dependency('coderay', '~> 1.1')
  s.add_development_dependency('rspec', '~> 3.9') 
  s.add_development_dependency('sqlite3', '~> 1.4')
  s.add_development_dependency('test-unit', '~> 3.0')
   
  ## ----------------------------------------------

  s.post_install_message = "#{'1F4E1'.hex.chr('UTF-8')} EOCFI  #{'1F47E'.hex.chr('UTF-8')} eocfi #{EOCFI.class_variable_get(:@@version)} installed \360\237\215\200 \360\237\215\200 \360\237\215\200 \n\
#{'1F680'.hex.chr('UTF-8')} EOCFI #{'1F6F0'.hex.chr('UTF-8')}  EOCFI version #{EOCFI.class_variable_get(:@@ESA_EOCFI_VERSION)} #{'1F483'.hex.chr('UTF-8')} #{'1F483'.hex.chr('UTF-8')} #{'1F483'.hex.chr('UTF-8')}\n\
#{EOCFI.class_variable_get(:@@ESA_EOCFI_URL)}"
    
  ## ----------------------------------------------
     
end

### ============================================================================
