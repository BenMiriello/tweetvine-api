class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def user_serialized
    {
      name: @user.name,
      email: @user.email,
    }
  end

  def user_json
    response_obj = {}

    user_messages = @user ? @user.errors.full_messages : nil
    if user_messages && @errors ||= user_messages[0] ? user_messages : nil
      response_obj[:errors] = @errors
    end

    if @user && @jwt
      response_obj[:user] = user_serialized
      response_obj[:jwt] = @jwt
    end

    response_obj
  end
end
