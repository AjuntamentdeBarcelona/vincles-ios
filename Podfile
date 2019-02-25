# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'VinclesDev' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
    pod 'ContextMenu'
    pod 'SwiftGen', '5.2.1'
    pod 'AlamofireImage', '~> 3.3'
    pod 'Alamofire', '~> 4.6'
    pod 'SwiftyJSON', '~> 4.0'
    pod 'OHHTTPStubs', '~> 6.1'
    pod 'OHHTTPStubs/Swift'
    pod 'SVProgressHUD'
    pod 'RealmSwift', '~> 3.1'
    pod 'SlideMenuControllerSwift', '~> 4.0'
    pod 'Popover', '~> 1.2'
    pod 'SimpleImageViewer', '~> 1.1'
    pod 'BEMCheckBox', '~> 1.4'
    pod 'NextGrowingTextView', '~> 1.2'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'IQKeyboardManagerSwift'
    pod 'SwiftyTimer', '~> 2.0'
    pod 'webrtcat4', :path => './'
    pod 'AudioPlayerSwift'
    pod 'ReachabilitySwift'
    pod 'VersionControl', :git => 'https://github.com/AjuntamentdeBarcelona/osam-controldeversions-ios.git', :tag => '2.9'
    pod 'Google/Analytics'
    pod 'Google/SignIn'
    pod 'CoreDataManager', '~> 0.8.2'
    pod 'CryptoSwift'
    pod 'KeychainAccess'

target 'VinclesDevTests' do
    inherit! :search_paths

  end

  target 'VinclesDevUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# Change Bitcode setting for webrtcat4 Pod
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if target.name == 'webrtcat4'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
      else
        config.build_settings['ENABLE_BITCODE'] = 'YES'
      end
    end
  end
end

