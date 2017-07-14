Pod::Spec.new do |s|
  s.name             =  'Pelias'
  s.version          =  '1.0.2'
  s.summary          =  'A distributed full-text geographic search engine. An open source project sponsored by Mapzen.'
  s.homepage         =  'https://github.com/pelias/pelias-ios-sdk'
  s.social_media_url =  'https://twitter.com/mapzen'
  s.author           =  { 'Matt Smollinger' => 'm.smollinger@gmail.com' }
  s.source           =  { :git => 'https://github.com/pelias/pelias-ios-sdk.git', :tag => "v#{s.version}" }
  s.license          =  'Apache License, Version 2.0'

  # Platform setup
  s.requires_arc = true
  s.ios.deployment_target = '9.3'
  s.osx.deployment_target = '10.11'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

  # Exclude optional Convenience modules
  s.default_subspec = 'Core'

  ### Subspecs

  s.subspec 'Core' do |cs|
    cs.source_files   = 'Sources/Core/*.swift'
  end
end
