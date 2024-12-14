# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'ChineseChessHelper' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChineseChessHelper
  pod 'FMDB'
  pod 'Google-Mobile-Ads-SDK'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseAnalytics'
  pod 'SSZipArchive'
  pod 'MBProgressHUD', '~> 1.2.0'
  pod 'Toast', '~> 4.0.0'
  pod 'Masonry'
  pod 'LookinServer', :configurations => ['Debug']
  pod 'MLeaksFinder', :configurations => ['Debug'], :git => "https://github.com/Tencent/MLeaksFinder", :branch => "master"
end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            end
        end
    end
end
