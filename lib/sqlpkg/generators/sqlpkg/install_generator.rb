# frozen_string_literal: true

require "rails/generators/base"

module Sqlpkg
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def ensure_sqlpkg_project_scope_directory
        empty_directory ".sqlpkg"
      end

      def create_empty_sqlpkg_lockfile
        create_file "sqlpkg.lock", <<~CONTENT
          {
              "packages": {}
          }
        CONTENT
      end

      def copy_initializer_file
        return if defined? EnhancedSQLite3::Adapter

        template "initializer.rb", "config/initializers/sqlpkg.rb"
      end
    end
  end
end
