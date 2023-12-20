#
#  Rake tasks to manage native gem packages with binary executables from nalgeon/sqlpkg-cli
#
#  TL;DR: run "rake package"
#
#  The native platform gems (defined by Sqlpkg::Upstream::NATIVE_PLATFORMS) will each contain
#  two files in addition to what the vanilla ruby gem contains:
#
#     exe/
#     ├── sqlpkg                             #  generic ruby script to find and run the binary
#     └── <Gem::Platform architecture name>/
#         └── sqlpkg                         #  the sqlpkg binary executable
#
#  The ruby script `exe/sqlpkg` is installed into the user's path, and it simply locates the
#  binary and executes it. Note that this script is required because rubygems requires that
#  executables declared in a gemspec must be Ruby scripts.
#
#  As a concrete example, an x86_64-linux system will see these files on disk after installing
#  sqlpkg-0.x.x-x86_64-linux.gem:
#
#     exe/
#     ├── sqlpkg
#     └── x86_64-linux/
#         └── sqlpkg
#
#  So the full set of gem files created will be:
#
#  - pkg/sqlpkg-1.0.0.gem
#  - pkg/sqlpkg-1.0.0-arm64-linux.gem
#  - pkg/sqlpkg-1.0.0-arm64-darwin.gem
#  - pkg/sqlpkg-1.0.0-x86_64-darwin.gem
#  - pkg/sqlpkg-1.0.0-x86_64-linux.gem
#
#  Note that in addition to the native gems, a vanilla "ruby" gem will also be created without
#  either the `exe/sqlpkg` script or a binary executable present.
#
#
#  New rake tasks created:
#
#  - rake gem:ruby           # Build the ruby gem
#  - rake gem:arm64-linux  # Build the aarch64-linux gem
#  - rake gem:arm64-darwin   # Build the arm64-darwin gem
#  - rake gem:x86_64-darwin  # Build the x86_64-darwin gem
#  - rake gem:x86_64-linux   # Build the x86_64-linux gem
#  - rake download           # Download all sqlpkg binaries
#
#  Modified rake tasks:
#
#  - rake gem                # Build all the gem files
#  - rake package            # Build all the gem files (same as `gem`)
#  - rake repackage          # Force a rebuild of all the gem files
#
#  Note also that the binary executables will be lazily downloaded when needed, but you can
#  explicitly download them with the `rake download` command.
#
require "rubygems/package"
require "rubygems/package_task"
require "open-uri"
require "zlib"
require "zip"
require_relative "../lib/sqlpkg/upstream"

def sqlpkg_download_url(filename)
  "https://github.com/nalgeon/sqlpkg-cli/releases/download/#{Sqlpkg::Upstream::VERSION}/#{filename}"
end

SQLPKG_RAILS_GEMSPEC = Bundler.load_gemspec("sqlpkg.gemspec")

gem_path = Gem::PackageTask.new(SQLPKG_RAILS_GEMSPEC).define
desc "Build the ruby gem"
task "gem:ruby" => [gem_path]

exepaths = []
Sqlpkg::Upstream::NATIVE_PLATFORMS.each do |platform, filename|
  SQLPKG_RAILS_GEMSPEC.dup.tap do |gemspec|
    exedir = File.join(gemspec.bindir, platform) # "exe/x86_64-linux"
    exepath = File.join(exedir, "sqlpkg") # "exe/x86_64-linux/sqlpkg"
    exepaths << exepath

    # modify a copy of the gemspec to include the native executable
    gemspec.platform = platform
    gemspec.files += [exepath, "LICENSE-DEPENDENCIES"]

    # create a package task
    gem_path = Gem::PackageTask.new(gemspec).define
    desc "Build the #{platform} gem"
    task "gem:#{platform}" => [gem_path]

    directory exedir
    file exepath => [exedir] do
      release_url = sqlpkg_download_url(filename)
      warn "Downloading #{exepath} from #{release_url} ..."

      # lazy, but fine for now.
      URI.open(release_url) do |remote| # standard:disable Security/Open
        if release_url.end_with?(".zip")
          Zip::File.open_buffer(remote) do |zip_file|
            zip_file.extract("sqlpkg", exepath)
          end
        elsif release_url.end_with?(".gz")
          Zlib::GzipReader.wrap(remote) do |gz|
            Gem::Package::TarReader.new(gz) do |reader|
              reader.seek("sqlpkg") do |file|
                File.binwrite(exepath, file.read)
              end
            end
          end
        end
      end
      FileUtils.chmod(0o755, exepath, verbose: true)
    end
  end
end

desc "Download all sqlpkg binaries"
task "download" => exepaths
