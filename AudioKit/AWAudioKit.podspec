Pod::Spec.new do |s|
  s.name             = "AWAudioKit"
  s.version          = "0.2.0"
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

  # s.source_files = 'AWAudioKit/**/*.{h,m,mm,c}'

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
  s.default_subspec = "AWAudioKit-Core", "AWAudioRecorder", "AWAudioPlayer"

  ## subspecs
  s.subspec 'AWAudioKit-Core' do |ss|
    ss.header_dir = 'AWAudioKit/AWAudioKit-Core/'
    ss.public_header_files = 'AWAudioKit/AWAudioKit-Core/**/*.h'
    ss.source_files = 'AWAudioKit/AWAudioKit-Core/**/*.{h,m}'
    ss.resources = 'AWAudioKit/AWAudioKit-Core/**/*.{png,xib,plist}'

    ss.dependency	"AFNetworking", '2.6.0'
    ss.dependency	"YYCache"
  end

  s.subspec 'AWAudioRecorder' do |ss|
    ss.header_dir = 'AWAudioKit/AWAudioRecorder/'
    ss.public_header_files = 'AWAudioKit/AWAudioRecorder/**/*.h'
    ss.source_files = 'AWAudioKit/AWAudioRecorder/**/*.{h,m}'
    ss.resources = 'AWAudioKit/AWAudioRecorder/**/*.{png,xib,plist}'
    ss.vendored_frameworks = 'AWAudioKit/AWAudioRecorder/Libraries/**/*.framework'
    ss.vendored_libraries = 'AWAudioKit/AWAudioRecorder/Libraries/**/*.a'
  end

  s.subspec 'AWAudioPlayer' do |ss|
    ss.header_dir = 'AWAudioKit/AWAudioPlayer/'
    ss.public_header_files = 'AWAudioKit/AWAudioPlayer/**/*.h'
    ss.source_files = 'AWAudioKit/AWAudioPlayer/**/*.{h,m}'
    ss.resources = 'AWAudioKit/AWAudioPlayer/**/*.{png,xib,plist}'
    ss.vendored_frameworks = 'AWAudioKit/AWAudioPlayer/Libraries/**/*.framework'
    ss.vendored_libraries = 'AWAudioKit/AWAudioPlayer/Libraries/**/*.a'
  end


end
