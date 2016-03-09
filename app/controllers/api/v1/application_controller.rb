module API
  module V1
    class ApplicationController < ::Grape::API
      version 'v1'
      format :json
      prefix :api

      get '/status' do
        {
          status:             200,
          message:            'API Working Perfectly',
          database: {
            connected: App.instance.database_connection.connected?,
            config:    App.instance.connection_config
          }
        }
      end

      mount API::V1::UsersController
    end
  end
end
