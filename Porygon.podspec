# frozen_string_literal: true

Pod::Spec.new do |spec|
  spec.name = 'Porygon'
  spec.version = '0.1.0'
  spec.summary = 'A Combine-oriented networking library.'

  spec.description = <<-DESC
  Porygon is a networking library heavily inspired by
  [tiny-networking](https://github.com/objcio/tiny-networking), but designed
  primarily for use with Combine. It defines an `Endpoint` type which
  encapsulates the relationship between a `URLRequest` and the `Decodable`
  entity it represents.
  DESC

  spec.homepage = 'https://github.com/rhysforyou/Porygon'

  spec.license = { type: 'Unlicense', file: 'LICENSE' }

  spec.authors = { 'Rhys Powell' => 'rhys@rpowell.me' }
  spec.social_media_url = 'https://twitter.com/rhysforyou'

  spec.ios.deployment_target = '13.0'
  spec.osx.deployment_target = '10.15'
  spec.watchos.deployment_target = '6.0'
  spec.tvos.deployment_target = '13.0'

  spec.source = {
    git: 'https://github.com/rhysforyou/Porygon.git',
    tag: spec.version.to_s
  }

  spec.source_files = 'Sources/Porygon/*.swift'

  spec.frameworks = ['Combine']
  spec.swift_versions = ['5.0', '5.1']
end
