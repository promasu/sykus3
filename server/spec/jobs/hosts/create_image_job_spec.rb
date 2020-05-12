require 'spec_helper'

require 'jobs/hosts/create_image_job'
require 'jobs/hosts/import_packages_job'

module Sykus

  describe Hosts::CreateImageJob do
    let (:files) {[ 
      '/var/lib/sykus3/image/release.img',
      '/var/lib/sykus3/image/release.img.size',
    ]}

    it 'creates a new image', slow: true do
      files.each { |f| FileUtils.rm_f f }

      Hosts::ImportPackagesJob.perform

      Hosts::Package.each do |package|
        package.selected = true
        package.save
      end

      Hosts::CreateImageJob.perform true

      files.each do |f|
        File.exist?(f).should be_true
      end
    end
  end

end


