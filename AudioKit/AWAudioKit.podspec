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

    ss.subspec 'MLAudioRecorder' do |ssp|
      ssp.header_dir = 'AWAudioKit/Libraries/MLAudioRecorder/'
      ssp.public_header_files = 'AWAudioKit/Libraries/MLAudioRecorder/**/*.h'
      ssp.source_files = 'AWAudioKit/Libraries/MLAudioRecorder/**/*.{h,m}'
      ss.vendored_libraries = 'AWAudioKit/Libraries/MLAudioRecorder/**/*.a'
      ss.vendored_frameworks = 'AWAudioKit/Libraries/MLAudioRecorder/**/*.framework'
      # 如果需要使用mp3或者Caf音频的转换功能，将其从exclude_files中删除即可
      ssp.exclude_files = [
          # 'Libraries/MLAudioRecorder/AmrRecordWriter.{h,m}',
          'AWAudioKit/Libraries/MLAudioRecorder/CafRecordWriter.{h,m}',
          'AWAudioKit/Libraries/MLAudioRecorder/Mp3RecordWriter.{h,m}',
      ]

      ssp.frameworks = 'AVFoundation'
    end

    ss.subspec 'MLAudioPlayer' do |ssp|
      ssp.header_dir = 'AWAudioKit/Libraries/MLAudioPlayer/'
      ssp.public_header_files = 'AWAudioKit/Libraries/MLAudioPlayer/**/*.h'
      ssp.source_files = 'AWAudioKit/Libraries/MLAudioPlayer/**/*.{h,m}'

      ssp.frameworks = 'AVFoundation'
    end

    ss.subspec 'MLDataCache' do |ssp|
      ssp.header_dir = 'AWAudioKit/Libraries/MLDataCache/'
      ssp.public_header_files = 'AWAudioKit/Libraries/MLDataCache/**/*.h'
      ssp.source_files = 'AWAudioKit/Libraries/MLDataCache/**/*.{h,m}'
    end

    ss.dependency	"AFNetworking", '2.6.0'
    ss.dependency	"YYCache"
  end


end
