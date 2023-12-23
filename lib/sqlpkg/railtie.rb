# frozen_string_literal: true

require "rails/railtie"

module Sqlpkg
  class Railtie < ::Rails::Railtie
    # Load the `sqlpkg:install` generator into the host Rails app
    generators do
      require_relative "generators/sqlpkg/install_generator"
    end
  end
end
