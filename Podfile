platform :ios, '10.0'

use_frameworks!

# ignore all warnings from all pods
#inhibit_all_warnings!

abstract_target 'All' do
  pod 'RMBTClient', :path => './rmbt-ios-client'
  
  pod 'TUSafariActivity'
  pod 'GoogleMaps'
  pod 'BCGenieEffect'
  pod 'SVProgressHUD'
  pod 'KINWebBrowser', :git => 'https://github.com/sglushchenko/KINWebBrowser', :branch => 'master'
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'
  pod 'FacebookSDK'
  pod 'FacebookCore'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Mapbox-iOS-SDK'
  pod 'Kingfisher'
  pod "MarkdownView"
  
  # now in the folder Vendor
  #pod 'SWRevealViewController', '~> 2.3.0' # TODO: not possible to use the version from cocoapods because tb changed something in the implementation...
  
  pod 'ActionKit'
  
  pod 'XCGLogger'
  
  target 'RMBT_ONT' do
    
    target 'UnitTests' do
      inherit! :search_paths
    end
    
    target 'UITests' do
      inherit! :search_paths
    end
  end
  
#  post_install do |installer|
#      installer.pods_project.targets.each do |target|
#          target.build_configurations.each do |config|
#              config.build_settings['SWIFT_VERSION'] = '4.0'
#              config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
#          end
#      end
#  end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
  end
end

end
