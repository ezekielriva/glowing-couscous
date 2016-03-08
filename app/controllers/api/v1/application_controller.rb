module API
  module V1
    class ApplicationController < ::Grape::API
      version 'v1'
      format :json
      prefix :api

      get '/status' do
        { status: 200, message: 'API Working Perfectly' }
      end
    end
  end
end
