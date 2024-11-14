# Uncomment the next line to define a global platform for your project
platform :ios, '17.5'

target 'HootMessenger' do
  use_frameworks!

#Firebase
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'

# Google Sign In
pod 'GoogleSignIn'

# Others
pod 'MessageKit'
pod 'JGProgressHUD'
pod 'RealmSwift'
pod 'SDWebImage'

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end

end
