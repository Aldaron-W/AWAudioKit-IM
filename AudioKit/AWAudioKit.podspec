Pod::Spec.new do |s|
  s.name             = "AWAudioKit"
  s.version          = "0.1.0"
  s.summary          = "AWKit"
  s.source           = { :path => "./" }
  s.social_media_url = 'http://www.aldaron.cn'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  # s.compiler_flags = '-ObjC'
  s.xcconfig = { 'ONLY_ACTIVE_ARCH' => 'NO' }

  s.public_header_files = 'AWAudioKit/**/*.h'

  s.prefix_header_contents = %(

  )

  s.source_files = 'AWAudioKit/**/*.{h,m,mm,c}'

  s.header_dir = './'

  s.frameworks = ['UIKit', 'Foundation', 'CoreGraphics', 'CFNetwork', 'CoreTelephony',
    'MobileCoreServices', 'SystemConfiguration', 'CoreLocation', 'AdSupport', 'Security', 'ImageIO',
    'AddressBook', 'QuartzCore', 'MessageUI', 'AVFoundation'
  ]
  # s.libraries = 'xml2.2'
  # s.vendored_libraries = [
  #   'MFWSdk/AdTracking/MFWSdk/Libraries/AdTracking/libTalkingDataAppCpa.a',
  #   'MFWSdk/RSA/MFWSdk/Libraries/RSA/openssl/lib/libcrypto.a',
  #   'MFWSdk/RSA/MFWSdk/Libraries/RSA/openssl/lib/libssl.a',
  #   'MFWSdk/MFWClick/SubRepos/MFWClick/AnalyticsSDK/TalkingData/libTalkingData.a',
  #   'MFWSdk/MFWClick/SubRepos/MFWClick/AnalyticsSDK/Umeng/libMobClickLibrary.a'
  # ]

  s.exclude_files = [
  ]

  s.resources = ''
  s.default_subspec = "AWAudioKit-Core"

  ## subspecs
  s.subspec 'AWAudioKit-Core' do |ss|
    ss.header_dir = 'AWAudioKit/AWAudioKit-Core/'
    ss.public_header_files = 'AWAudioKit/AWAudioKit-Core/**/*.h'
    ss.source_files = 'AWAudioKit/AWAudioKit-Core/**/*.{h,m}'
    ss.resources = 'AWAudioKit/AWAudioKit-Core/**/*.{png,xib,plist}'

    ss.dependency	"AFNetworking", '2.6.0'
    ss.dependency	"YYCache"
  end


end
