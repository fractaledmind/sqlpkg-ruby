# frozen_string_literal: true

require "test_helper"
require "rails/generators"
require "sqlpkg/generators/sqlpkg/install_generator"

class SqlpkgGeneratorTest < Rails::Generators::TestCase
  tests Sqlpkg::Generators::InstallGenerator
  destination File.expand_path("../tmp", __dir__)

  setup :prepare_destination

  def after_teardown
    FileUtils.rm_rf destination_root
    super
  end

  test "should generate project scope directory" do
    run_generator

    assert_directory ".sqlpkg"
  end

  test "should generate lockfile" do
    run_generator

    assert_file "sqlpkg.lock"
  end

  test "should generate initializer" do
    run_generator

    assert_file "config/initializers/sqlpkg.rb" do |content|
      assert_match "@raw_connection.load_extension(extension_path)", content
    end
  end
end
