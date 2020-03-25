Pod::Spec.new do |s|

    s.name             = "BrightcovePlayerPlugin"
    s.version          = '1.4.4'
    s.summary          = "BrightcovePlayer video player framework for Zapp iOS."
    s.description      = <<-DESC
                          BrightcovePlayer video player framework for Zapp iOS.
                         DESC
    s.homepage         = "https://github.com/applicaster/zapp-player-plugin-brightcove"
    s.license          = 'MIT'
    s.author           = { "Roman Karpievich" => "karpievich@scand.com" }
    s.source           = { :git => "https://github.com/applicaster/zapp-player-plugin-brightcove.git", :tag => s.version.to_s }
  
    s.platform = :ios
    s.ios.deployment_target = "10.0"
    s.requires_arc = true
    s.swift_version = '5.0'
    s.static_framework = true
    s.resources = ['iOS/Resources/Images/*.png', 'iOS/PluginClasses/*.{xib,nib,storyboard}']
    s.source_files = 'iOS/PluginClasses/**/*.{swift,h,m}'
    s.dependency 'ZappPlugins'
    s.dependency 'Brightcove-Player-IMA'
    s.xcconfig =  { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
                    'ENABLE_BITCODE' => 'YES',
                    'SWIFT_VERSION' => '5.0'
                  }
    
  end
  
