class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
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

  def user_serialized
    {
      name: @user.name,
      email: @user.email,
    }
  end

  def with_user(errors = nil)
    user_messages = @user ? @user.errors.full_messages : nil
    if errors ||= user_messages[0] ? user_messages : nil
      {
        user: user_serialized,
        errors: errors,
      }
    else
      { user: user_serialized }
    end
  end
end
