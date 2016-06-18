#
# Be sure to run `pod lib lint RTViewAttachment.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RTViewAttachment'
  s.version          = '0.1.1'
  s.summary          = 'A solution for attaching a `UIView` to a text editor'
  s.description      = <<-DESC
Since **iOS 7**, developers can attach a `NSTextAttachemnt` to a `UITextView`, and it will display as an image. What if I want to attach a `UIView` to a text editor, and it can layout with all other text?

Here comes a solution. This project is based on `NSTextAttachment`, and no private API is used, no Black Magic.
                       DESC

  s.homepage         = 'https://github.com/rickytan/RTViewAttachment'
  s.screenshots      = 'https://raw.githubusercontent.com/rickytan/RTViewAttachment/master/Screenshot/1.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ricky Tan' => 'ricky.tan.xin@gmail.com' }
  s.source           = { :git => 'https://github.com/rickytan/RTViewAttachment.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'RTViewAttachment/Classes/**/*'

  s.frameworks = 'UIKit', 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
