Pod::Spec.new do |s|
  s.name         = "PCLBlurEffectAlert"
  s.version      = "1.1.0"
  s.summary      = "Custom Swift AlertController."
  s.homepage     = "https://github.com/hryk224/PCLBlurEffectAlert"
  s.screenshots  = "https://raw.githubusercontent.com/wiki/hryk224/PCLBlurEffectAlert/images/sample1.gif"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "hyyk224" => "hryk224@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/hryk224/PCLBlurEffectAlert.git", :tag => "#{s.version}" }
  s.source_files  = "PCLBlurEffectAlert/*.{h,swift}"
  s.frameworks = "UIKit"
  s.requires_arc = true
end
