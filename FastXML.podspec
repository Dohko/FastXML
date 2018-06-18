Pod::Spec.new do |s|
  s.name         = "FastXML"
  s.version      = "1.2.0"
  s.summary      = "Fast XML parsing library."

  s.description  = <<-DESC
  Fast XML parsing library in Swift.
  Developer: Morgan Fitussi
                   DESC
  s.homepage     = "https://github.com/Dohko/FastXML"
  s.license = { :type => "MIT" }
  s.author             = { "Morgan Fitussi" => "mfitussi@gmail.com" }
  s.swift_version = "4.1"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/Dohko/FastXML.git", :tag => "#{s.version}" }
  s.source_files = "Source/*.swift"
end
