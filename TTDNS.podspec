#
#  Be sure to run `pod spec lint TTComponent.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "TTDNS"
  spec.version      = "0.0.2"
  spec.summary      = "TTDNS"
  spec.description  = <<-DESC
                        基础组件所有业务组件需要继承
                        DESC
  
  spec.homepage     = "https://github.com/simpossible/TTDNS"
  spec.license      = "MIT"
  spec.author             = { "simpossible" => "963571744@qq.com" }
  spec.platform     = :ios, "9.0"
  spec.swift_version = '5.0'
  spec.ios.deployment_target = "9.0"
  
  spec.source       = { :git => "https://github.com/simpossible/TTDNS.git", :tag => "#{spec.version}" }
  
  spec.static_framework = true
  spec.source_files  = "TTDNS", "TTDNS/**/*.{h,m,swift}"
  spec.public_header_files = "TTDNS/**/*.{h}"
  
  # spec.resources = "TTDNS/**/*.{xib,storyboard}"

  spec.static_framework = true
  
  # spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  # spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }

  spec.subspec "Base" do |ss|
     ss.source_files  = "TTDNS", "TTDNS/**/*.{h,m,swift}"
    ss.public_header_files = "TTDNS/**/*.{h}"
  end
  
  
  # spec.dependency "Log"
  spec.dependency "AFNetworking"  

  spec.subspec "TencentLoader" do |ss|
    ss.dependency "MSDKDns_C11"
    ss.source_files  = "LoaderAdaptor/tencent/**/*.{h,m,swift}"
    ss.public_header_files = "LoaderAdaptor/tencent/**/*.{h}"
    ss.dependency "TTDNS/Base"
  end

  # spec.subspec "AliLoader" do |ss|
  #    ss.source_files  = "LoaderAdaptor/alibaba/**/*.{h,m,swift}"
  #    ss.public_header_files = "LoaderAdaptor/alibaba/**/*.{h}"
  #    ss.dependency "AlicloudHTTPDNS"
  # end
  # spec.test_spec 'Tests' do |test_spec|
  #   test_spec.source_files = 'Tests/*.{h,m,swift}'
  #   test_spec.dependency  'XcodeCoverage'
  #   test_spec.dependency  'OCMock'
  #   test_spec.libraries = 'swiftWebKit','swiftSwiftOnoneSupport'
  #   test_spec.pod_target_xcconfig = {"OTHER_LDFLAGS" => "-undefined dynamic_lookup"}
  # end

end
