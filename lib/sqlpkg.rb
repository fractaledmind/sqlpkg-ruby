# frozen_string_literal: true

module Sqlpkg
end

require_relative "sqlpkg/version"
require_relative "sqlpkg/upstream"
require_relative "sqlpkg/commands"
require_relative "sqlpkg/railtie" if defined?(::Rails::Railtie)
