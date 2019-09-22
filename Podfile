# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
  pod 'RealmSwift'
end

target 'maxwise' do

  use_frameworks!

  pod 'TesseractOCRiOS'
  pod 'FoursquareAPIClient'
  pod 'Charts'
  shared_pods

  target 'maxwiseTests' do
    inherit! :search_paths

  end

end

target 'ExpenseKit' do
  use_frameworks!
  shared_pods
  
end
