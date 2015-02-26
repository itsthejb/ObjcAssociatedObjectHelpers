target :ObjcAssociatedObjectHelpers, :exclusive => true do
end

def test_pods
  pod 'ReactiveCocoa', '2.2.3'
  pod 'Expecta', :head
  pod 'Specta', :head
end

target :ObjcAssociatedObjectHelpersTests, :exclusive => true do
  platform :osx, '10.7'
  test_pods
end

target :ObjcAssociatedObjectHelpersLibTests, :exclusive => true do
  platform :ios, '5.1.1'
  test_pods
end

inhibit_all_warnings!
