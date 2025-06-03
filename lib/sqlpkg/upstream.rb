module Sqlpkg
  # constants describing the upstream sqlpkg-cli project
  module Upstream
    VERSION = "0.3.0"

    # rubygems platform name => upstream release filename
    NATIVE_PLATFORMS = {
      "arm64-darwin" => "sqlpkg-cli_#{VERSION}_darwin_arm64.tar.gz",
      "arm64-linux" => "sqlpkg-cli_#{VERSION}_linux_arm64.tar.gz",
      "x86_64-darwin" => "sqlpkg-cli_#{VERSION}_darwin_amd64.tar.gz",
      "x86_64-linux" => "sqlpkg-cli_#{VERSION}_linux_amd64.tar.gz"
    }
  end
end
