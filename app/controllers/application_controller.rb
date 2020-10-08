class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def user_serialized
    {
      name: @user.name,
      email: @user.email,
    }
  end

  def user_json(errors = nil)
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

  def user_jwt
    if @jwt && @user_json = user_json
      @user_json[:jwt] = @jwt
    end
  end
end
