# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ReverseImageSearch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ReverseImageSearch
  pod 'SnapKit'
  pod 'SwiftGen'
  pod 'SwiftyStoreKit', :git => 'https://github.com/bizz84/SwiftyStoreKit', :branch => 'develop'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Storage'
  pod 'CropViewController'
  pod 'Alamofire'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Uploadcare', git: 'https://github.com/uploadcare/uploadcare-swift'

end
post_install do |installer|
  installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
             end
        end
 end
end
