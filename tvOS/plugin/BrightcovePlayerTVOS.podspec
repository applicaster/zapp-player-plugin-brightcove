Pod::Spec.new do |s|
	s.name = "BrightcovePlayerTVOS"
	s.version = "0.0.1"
	s.platform = :tvos, :ios
	s.swift_version = '5.0'
	s.summary = "ZappPlugins"
	s.description = "Brightcove player for tvos"
	s.homepage = "https://applicaster.com"
	s.license = ''
	s.author = "Applicaster LTD."
	s.source = {
		 :git => 'git@github.com:applicaster/zapp-player-plugin-brightcove.git',
		 :tag => s.version.to_s
  }
	s.dependency 'React'
	s.dependency 'ZappPlugins'
        s.dependency 'Brightcove-Player-Core/dynamic'
	s.xcconfig = { 
		 'ENABLE_BITCODE' => 'YES',
		 'ENABLE_TESTABILITY' => 'YES',
		 'OTHER_CFLAGS'  => '-fembed-bitcode',
		 'SWIFT_VERSION' => '5.0',
		}

	 s.tvos.deployment_target = "10.0"
	 s.ios.deployment_target = "10.0"

	 s.source_files  = [
		'BrightcovePlayerTVOS/**/*.{swift}',
		'BrightcovePlayerTVOS/Helpers/ReactNative/ReactNativeModulesExports.m'
	 ]
	 s.exclude_files = [

	 ]

end
