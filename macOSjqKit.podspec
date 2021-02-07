#
# Be sure to run `pod lib lint macOSjqKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'macOSjqKit'
  s.version          = '1.0.4'
  s.summary          = 'An Objective-C wrapper around jqlib.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  An Objective-C wrapper around jqlib, the C library that powers the jq JSON filtering tool.
  See: https://stedolan.github.io/jq/
                       DESC

  s.homepage         = 'https://github.com/luckymarmot/jqKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = {
    'Stephen Dolan' => 'mu@netsoc.tcd.ie',
    'Nicolas Williams' => 'nico@cryptonector.com',
    'William Langford' => 'wlangfor@gmail.com',
    'Micha Mazaheri' => 'micha@paw.cloud'
  }
  s.source           = { :git => 'https://github.com/luckymarmot/jqKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/luckymarmot'

  s.platform = :osx
  s.osx.deployment_target = "10.10"

  s.source_files = 'jqKit/*.{m,h}', 'Dependencies/jq_install/include/*.h'
  s.public_header_files = 'jqKit/*.h', 'Dependencies/jq_install/include/*.h'
  s.header_dir = 'Dependencies/jq_install/include'
  s.preserve_paths = 'Dependencies/onig_install/lib/libonig.a', 'Dependencies/jq_install/lib/libjq.a'
  s.vendored_libraries = 'Dependencies/onig_install/lib/libonig.a', 'Dependencies/jq_install/lib/libjq.a'
  s.module_name = 'macOSjqKit'
end
