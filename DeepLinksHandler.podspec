
Pod::Spec.new do |s|
  s.name             = 'DeepLinksHandler'
  s.version          = '1.1.3'
  s.summary          = 'Convinient utility to handle external and internal URLs.'
  s.ios.deployment_target = '8.0'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Maksim Kurpa' => 'maksim.kurpa@gmail.com' }
  s.description      = 'DeepLinksHandler is the easiest way to handle internal and external URLs in your project!'
  s.homepage         = 'https://github.com/MaksimKurpa/DeepLinksHandler'
  s.source       = { :git => 'https://github.com/MaksimKurpa/DeepLinksHandler.git', :branch => 'master',:tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/maksim.kurpa'
  s.source_files = 'DeepLinksHandler/*.{h,m}'
  s.requires_arc = true
end
