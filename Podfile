# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ChatFlix' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChatFlix

  # TheMovieDB API
  pod 'Moya'
  pod 'Kingfisher'

  # Google Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'

  # Chat
  pod 'JSQMessagesViewController'

  target 'ChatFlixTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ChatFlixUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  # Copy Pods Acknowledgements to a convenient location
  post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-ChatFlix/Pods-ChatFlix-acknowledgements.plist', 'ChatFlix/Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  end

end
