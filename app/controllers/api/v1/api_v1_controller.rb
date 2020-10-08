class ApiV1Controller < ApplicationController
    before_action :authorize
    
    def authorize
      if !user_id = cookies.signed["_tweetvine"]
        render json: {}, status: :unauthorized
      elsif !@user = User.find(user_id)
        render json: {errors: ['No user found with provided id.']}, status: :unauthorized
      end
    end

    def set_session
      cookies.signed["_tweetvine"] = {
        value: @user.id,
        httponly: true,
        expires: 14.days.from_now,
        sameSite: 'none',
      }
      if Rails.env != 'development'
        cookies.signed["_tweetvine"].secure = 'true'
      end
    end
  end
