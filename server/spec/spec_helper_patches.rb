# Patches for testing gems.

# REVIEW: remove once new version gets released
#module FakeFS
#  class File
#    def self.size?(path)
#      return nil unless File.exists? path
#      size(path) > 0 ? size(path) : nil
#    end
#  end
#end

