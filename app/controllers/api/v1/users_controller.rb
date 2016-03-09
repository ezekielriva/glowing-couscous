module API
  module V1
    class UsersController < ::Grape::API
      resource :users do
        get '/' do
          User.all
        end
      end
    end
  end
end
