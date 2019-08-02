platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def common_pods
  pod 'CocoaLumberjack', '~> 3.4.0'
  pod 'MBProgressHUD', '~> 1.1.0'
end

sdk_version = '2.21.2'

target 'Quick Start' do
  pod 'VoxImplantSDK', sdk_version
end

target 'Quality Issues' do
  common_pods

  pod 'VoxImplantSDK', sdk_version
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
