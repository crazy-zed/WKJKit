#
#  Be sure to run `pod spec lint WKJKit.podsepc.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = 'WKJKit'
  s.version      = '1.0.0'
  s.summary      = 'WKJKit is a collection of tools containing multiple functions/UI components.'

  s.description  = <<-DESC
                    WKJKit is a collection of tools containing multiple functions/UI components, which can quickly build a project.
                   DESC

  s.homepage     = 'https://github.com/crazy-zed/WKJKit'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'zed.wang' => 'zed-coder@qq.com' }

  # ――― Source Info ――― #
  s.platform      = :ios, '9.0'
  s.source        = { :git => 'https://github.com/crazy-zed/WKJKit.git', :tag => s.version.to_s }
  s.source_files  = 'WKJKit/WKJKit.h'
  s.requires_arc  = true
  # spec.public_header_files = 'WKJKit/**/*.h'

  s.frameworks    = 'Foundation', 'UIKit'
  # s.static_framework = true
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'WKJKit/Core', 'WKJKit/Core/Extensions'
    ss.dependency 'UICKeyChainStore'
  end

  s.subspec 'Foundation' do |ss|
    ss.source_files = 'WKJKit/Foundation'
  end

  s.subspec 'UIKit' do |ss|
    ss.source_files = 'WKJKit/UIKit'
  end

end
