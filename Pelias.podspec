Pod::Spec.new do |s|
  s.name             =  'Pelias'
  s.version          =  '0.2.0'
  s.summary          =  'A distributed full-text geographic search engine. An open source project sponsored by Mapzen.'
  s.homepage         =  'https://github.com/pelias/pelias-ios-sdk'
  s.social_media_url =  'https://twitter.com/mapzen'
  s.author           =  { 'Matt Smollinger' => 'm.smollinger@gmail.com' }
  s.source           =  { :git => 'https://github.com/pelias/pelias-ios-sdk.git', :tag => "v#{s.version}" }
  s.license          =  'Apache License, Version 2.0'

  # Platform setup
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  # Exclude optional Convenience modules
  s.default_subspec = 'Core'

  ### Subspecs

  s.subspec 'Core' do |cs|
    cs.source_files   = 'src/core/*.swift'
  end

  s.subspec 'MapKitExtras' do |mk|
    mk.source_files = 'src/convenience/MapkitExtensions.swift'
    mk.frameworks   = 'MapKit', 'Contacts', 'CoreLocation'
    mk.dependency     'Pelias/Core'
  end

  s.subspec 'ObjectiveCompat' do |objc|
    objc.source_files = 'src/objc-compat/ObjectiveCompatibility.swift'
    objc.dependency     'Pelias/Core'
  end
end
