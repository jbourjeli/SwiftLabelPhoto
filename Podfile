platform :ios, '9.0'
use_frameworks!

target 'Photos++' do
	pod 'FMMosaicLayout'
	pod 'RealmSwift'
	pod 'Kingfisher' 
	pod 'SwiftOverlays', :git => 'https://github.com/peterprokop/SwiftOverlays.git', :branch => 'swift-3.0'
end

target 'Photos++Tests' do
	pod 'FMMosaicLayout'
	pod 'RealmSwift'
end

target 'Photos++UITests' do
	pod 'FMMosaicLayout'
	pod 'RealmSwift'
	pod 'EZLoadingActivity'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end

