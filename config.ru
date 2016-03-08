require './config/application.rb'

app = App.instance

api = app.init do
  # Mount here each enpoint
  mount API::V1::ApplicationController
end

run api
