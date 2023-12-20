require_relative "upstream"

module Sqlpkg
  module Commands
    DEFAULT_DIR = File.expand_path(File.join(__dir__, "..", "..", "exe"))
    GEM_NAME = "sqlpkg"

    # raised when the host platform is not supported by upstream sqlpkg's binary releases
    class UnsupportedPlatformException < StandardError
    end

    # raised when the sqlpkg executable could not be found where we expected it to be
    class ExecutableNotFoundException < StandardError
    end

    # raised when SQLPKG_INSTALL_DIR does not exist
    class DirectoryNotFoundException < StandardError
    end

    def self.platform
      [:cpu, :os].map { |m| Gem::Platform.local.send(m) }.join("-")
    end

    def self.executable(exe_path: DEFAULT_DIR)
      sqlpkg_install_dir = ENV["SQLPKG_INSTALL_DIR"]
      if sqlpkg_install_dir
        if File.directory?(sqlpkg_install_dir)
          warn "NOTE: using SQLPKG_INSTALL_DIR to find sqlpkg executable: #{sqlpkg_install_dir}"
          exe_path = sqlpkg_install_dir
          exe_file = File.expand_path(File.join(sqlpkg_install_dir, "sqlpkg"))
        else
          raise DirectoryNotFoundException, <<~MESSAGE
            SQLPKG_INSTALL_DIR is set to #{sqlpkg_install_dir}, but that directory does not exist.
          MESSAGE
        end
      else
        if Sqlpkg::Upstream::NATIVE_PLATFORMS.keys.none? { |p| Gem::Platform.match_gem?(Gem::Platform.new(p), GEM_NAME) }
          raise UnsupportedPlatformException, <<~MESSAGE
            sqlpkg-ruby does not support the #{platform} platform
            Please install sqlpkg following instructions at https://github.com/nalgeon/sqlpkg-cli#download-and-install-preferred-method
          MESSAGE
        end

        exe_file = Dir.glob(File.expand_path(File.join(exe_path, "*", "sqlpkg"))).find do |f|
          Gem::Platform.match_gem?(Gem::Platform.new(File.basename(File.dirname(f))), GEM_NAME)
        end
      end

      if exe_file.nil? || !File.exist?(exe_file)
        raise ExecutableNotFoundException, <<~MESSAGE
          Cannot find the sqlpkg executable for #{platform} in #{exe_path}

          If you're using bundler, please make sure you're on the latest bundler version:

              gem install bundler
              bundle update --bundler

          Then make sure your lock file includes this platform by running:

              bundle lock --add-platform #{platform}
              bundle install

          See `bundle lock --help` output for details.

          If you're still seeing this message after taking those steps, try running
          `bundle config` and ensure `force_ruby_platform` isn't set to `true`. See
          https://github.com/fractaledmind/sqlpkg-ruby#check-bundle_force_ruby_platform
          for more details.
        MESSAGE
      end

      exe_file
    end
  end
end
