Pod::Spec.new do |s|

    s.name             = "BrightcovePlayerPlugin"
    s.version          = '1.1.0'
    s.summary          = "BrightcovePlayer video player framework for Zapp iOS."
    s.description      = <<-DESC
                          BrightcovePlayer video player framework for Zapp iOS.
                         DESC
    s.homepage         = "https://github.com/applicaster/zapp-player-plugin-brightcove"
    s.license          = 'MIT'
    s.author           = { "Roman Karpievich" => "karpievich@scand.com" }
    s.source           = { :git => "https://github.com/applicaster/zapp-player-plugin-brightcove.git", :tag => s.version.to_s }
  
    s.ios.deployment_target = "10.0"
    s.requires_arc = true
    s.swift_version = '4.2'
    s.static_framework = true
    s.resources = ['iOS/Resources/Images/*.png', 'iOS/PluginClasses/*.{xib,nib,storyboard}']

    s.subspec 'Core' do |c|
      c.frameworks = 'UIKit'
      c.source_files = 'iOS/PluginClasses/*.{swift,h,m}'
      c.dependency 'ZappPlugins'
      c.dependency 'Brightcove-Player-IMA'

    end
                  
    s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                    'ENABLE_BITCODE' => 'YES',
                    'SWIFT_VERSION' => '4.2'
                  }
                  
    s.default_subspec = 'Core'
                  
  end
  
