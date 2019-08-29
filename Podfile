platform :ios, '11.4'
use_frameworks!

# Shared pods
def shared_pods
	pod 'CocoaLumberjack'
	pod 'Mantle', '~> 2.1'
	pod 'JGProgressHUD'
	pod 'AFNetworking'
end

abstract_target 'Shared' do
	shared_pods

	target 'AlfrescoActiviti' do
        pod 'Fabric'
        pod 'Crashlytics'
        pod 'Buglife'
	end

	target 'ActivitiSDK' do
        target 'ActivitiSDKTests' do
            pod 'OCMock'
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
