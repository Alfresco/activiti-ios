platform :ios, '8.0'
use_frameworks!

# Shared pods
def shared_pods
	pod 'CocoaLumberjack'
	pod 'Mantle'
	pod 'JGProgressHUD'
	pod 'AFNetworking', '~> 2.0'
end

abstract_target 'Shared' do
	shared_pods

	target 'AlfrescoActiviti' do
        pod 'Fabric'
        pod 'Crashlytics'
	end

	target 'ActivitiSDK' do
	end
end

target 'AlfrescoActivitiTests' do
end

target 'ActivitiSDKTests' do
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
            cflags << '-fembed-bitcode'
            config.build_settings['OTHER_CFLAGS'] = cflags
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
