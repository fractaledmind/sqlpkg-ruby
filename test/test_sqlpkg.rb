# frozen_string_literal: true

require "test_helper"

class TestSqlpkg < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Sqlpkg::VERSION
  end

  def test_path_for_when_glob_returns_paths
    path = "./.sqlpkg/nalgeon/uuid/uuid.dylib"
    Dir.stub :glob, [path] do
      assert_equal path, Sqlpkg.path_for("nalgeon/uuid")
    end
  end

  def test_path_for_when_glob_returns_empty_array
    assert_raises Sqlpkg::ExtensionNotInstalledError do
      Sqlpkg.path_for("nalgeon/uuid")
    end
  end

  def test_accessor_when_glob_returns_paths
    path = "./.sqlpkg/nalgeon/uuid/uuid.dylib"
    Dir.stub :glob, [path] do
      assert_equal path, Sqlpkg["nalgeon/uuid"]
    end
  end

  def test_accessor_when_glob_returns_empty_array
    assert_raises Sqlpkg::ExtensionNotInstalledError do
      Sqlpkg["nalgeon/uuid"]
    end
  end
end
