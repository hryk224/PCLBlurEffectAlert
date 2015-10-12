Pod::Spec.new do |s|
  s.name         = "PCLAlertController"
  s.version      = "0.0.1"
  s.summary      = "Custom Swift AlertController."
  s.homepage     = "https://github.com/hryk224/PCLAlertController"
  s.screenshots  = ""
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "hyyk224" => "hryk224@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/hryk224/PCLAlertController.git", :tag => "#{s.version}" }
  s.source_files  = "Classes/*.swift", "Classes/*.xib"
  s.resource_bundles = {
    'PCL' => ["Classes/*.xib"]
  }
  s.frameworks = "UIKit"
  s.requires_arc = true
end
