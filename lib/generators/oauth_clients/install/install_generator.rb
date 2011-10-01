module OauthClients
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :file_name, :type => :string, :default => "oauth_clients"

      def self.banner
        "rails generate oauth_clients:#{generator_name} #{self.arguments.map{ |a| a.usage }.join(' ')}"
      end

      desc "This generator creates an oauth_clients.rb at config/initializers"
      def create_initializer_file
        template "oauth_clients.rb", "config/initializers/#{file_name.underscore}.rb"
      end
    end
  end
end
