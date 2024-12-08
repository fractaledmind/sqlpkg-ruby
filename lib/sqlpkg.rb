# frozen_string_literal: true

module Sqlpkg
  DIR = ".sqlpkg"
  FILE_PATTERN = "*.{dylib,so,dll}"

  Error = Class.new(StandardError)
  ExtensionNotInstalledError = Class.new(Error)

  class << self
    # File path for identified extension
    # => "./.sqlpkg/nalgeon/uuid/uuid.dylib"
    def path_for(identifier)
      path_glob = File.join(file_dir, identifier, FILE_PATTERN)
      path = Dir.glob(path_glob).first

      path || raise(ExtensionNotInstalledError, "No extension found for identifier: #{identifier}")
    end
    alias_method :[], :path_for

    # The directory where `sqlpkg` stores installed extensions
    # => "./.sqlpkg"
    def file_dir
      File.join(__dir__, DIR)
    end

    # List of file paths for all installed extensions
    # => ["./.sqlpkg/asg017/ulid/ulid0.dylib", "./.sqlpkg/nalgeon/uuid/uuid.dylib"]
    def installed_extension_paths
      Dir.glob File.join(file_dir, "**", FILE_PATTERN)
    end
  end
end

require_relative "sqlpkg/version"
require_relative "sqlpkg/upstream"
require_relative "sqlpkg/commands"
require_relative "sqlpkg/railtie" if defined?(::Rails::Railtie)
