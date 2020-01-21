source 'https://github.com/Alfresco/alfresco-private-podspecs-ios-sdk'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!

# Shared pods
def shared_pods
	pod 'CocoaLumberjack', '~> 3.6'
	pod 'Mantle', '~> 2.1'
	pod 'JGProgressHUD', '~> 2.1'
	pod 'AFNetworking', '~> 3.2'
    pod 'JWT'
end

abstract_target 'Shared' do
	shared_pods

	target 'AlfrescoActiviti' do
        pod 'Fabric', '~> 1.0'
        pod 'Crashlytics', '~> 3.14'
        pod 'Buglife', '~> 2.10'
        pod 'AlfrescoAuth'
        pod 'MaterialComponents' , '~> 92.5'
	end

	target 'ActivitiSDK' do
        target 'ActivitiSDKTests' do
            pod 'OCMock', '~> 3.4'
        end
	end
end

target 'AlfrescoActivitiTests' do
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
            cflags << '-fembed-bitcode'
            config.build_settings['OTHER_CFLAGS'] = cflags
            config.build_settings['ENABLE_BITCODE'] = 'YES'  
        end
    end
    
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Shared-AlfrescoActiviti/Pods-Shared-AlfrescoActiviti-acknowledgements.plist', 'AlfrescoActiviti/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

class ::Pod::Generator::Acknowledgements
    def footnote_text
        ""
    end
end
