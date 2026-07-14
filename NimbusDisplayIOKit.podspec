Pod::Spec.new do |spec|
    spec.name                   = 'NimbusDisplayIOKit'
    spec.version                = '0.0.1-development'
    spec.summary                = 'Enables display.io bidding through Nimbus'
    spec.homepage               = 'https://www.adsbynimbus.com'
    spec.social_media_url       = 'https://twitter.com/adsbynimbus'
    spec.author                 = 'Nimbus'
    spec.platform               = :ios, '13.0'
    spec.documentation_url      = 'https://docs.adsbynimbus.com/docs/sdk/ios'
    spec.license                = { :type => 'Copyright', :text => 'Nimbus. All rights reserved.' }
    spec.swift_versions         = ['5', '6']
    spec.ios.deployment_target  = '13.0'
    spec.static_framework       = true
    spec.source_files           = "Sources/NimbusDisplayIOKit/**/*.swift"
    spec.source                 = {
        :git => "https://github.com/adsbynimbus/nimbus-ios-displayio.git", 
        :tag => spec.version.to_s
    }

    spec.dependency 'NimbusSDK/NimbusKit', '~> 3'
    spec.dependency 'DIOSDK/Core', '>= 4.7.5', '< 5.0.0'
end
