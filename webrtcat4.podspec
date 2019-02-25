#
# Be sure to run `pod lib lint webrtcat4.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'webrtcat4'
  s.version          = '0.1.0'
  s.summary          = 'A short description of webrtcat4.'

  s.description      = <<-DESC
This project contains the WebRTCat4 client application for iOS as well as a reusable iOS module that can be included in other projects.
                       DESC

  s.homepage         = 'https://bitbucket.i2cat.net/projects/VC/repos/webrtcat4_ios/browse'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'develop' => 'develop@i2cat.net' }
  s.source           = { :git => 'https://develop@bitbucket.i2cat.net/scm/vc/webrtcat4_ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'webrtcat4/Classes/**/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'SocketRocket'
  s.dependency 'GoogleWebRTC'
  
end
