Pod::Spec.new do |s|
  s.name         = "ObjcAssociatedObjectHelpers"
  s.version      = "2.0.0"
  s.summary      = "Make working with associated objects much more pleasurable."
  s.description  = "A header file with macros that synthesize accessors for 
    associated objects, taking the boilerplate out of your hands. Also, a category
    that adds an NSMutableDictionary to NSObject to make adding abitrary key/values
    a breeze."
  s.homepage     = "https://github.com/itsthejb/ObjcAssociatedObjectHelpers"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Jonathan Crooke" => "joncrooke@gmail.com" }
	s.source       = { :git => "https://github.com/itsthejb/ObjcAssociatedObjectHelpers.git", :tag => "v#{s.version.to_s}" }
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.frameworks = 'Foundation'
  s.requires_arc = true

	s.subspec 'Core' do |c|
		c.source_files = 'ObjcAssociatedObjectHelpers/ObjcAssociatedObjectHelpers.{h,m}'
	end

  s.subspec 'NSObject+Dictionary' do |d|
    d.source_files = 'ObjcAssociatedObjectHelpers/NSObject+AssociatedDictionary.{h,m}'
    d.dependency 'ObjcAssociatedObjectHelpers/Core'
  end
end
