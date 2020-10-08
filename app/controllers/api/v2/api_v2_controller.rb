module Api::V2
  class ApiV2Controller < ApplicationController
    before_action :authorized

    def encode_token(payload)
      JWT.encode(payload, Rails.application.credentials.salt)
    end

    def auth_header
      request.headers['Authorization']
    end
    
    def decoded_token
      if auth_header
        token = auth_header.split(' ')[1]
        begin
          JWT.decode(token, Rails.application.credentials.salt, algorithm: 'HS256')
        rescue JWT::DecodeError
          nil
        end
      end
    end

    def current_user
      if decoded_token
        user_id = decoded_token[0]['user_id']
        @user = User.find_by(id: user_id)
      end
    end

    def logged_in?
      !!current_user
    end

    def authorized
      render json: { message: 'Not authorized.' }, status: :unauthorized unless logged_in?
    end
  end
end