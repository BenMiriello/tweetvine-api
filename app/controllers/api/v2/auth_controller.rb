module Api::V2
  class AuthController < ApiV2Controller
    skip_before_action :authorized, only: [:create]

    # POST /login
    def create
      @user = User.find_by(email: params[:user][:email]).try(:authenticate, params[:user][:password])
      if @user && @jwt = encode_token({ user_id: @user.id })
        render json: user_json, status: :accepted
      else
        render json: user_json, status: :unauthorized
      end
    end

    # GET /check_logged_in
    def check_logged_in
      if @user && @jwt = encode_token({ user_id: @user.id })
        render json: user_json, status: :ok
      else
        render json: user_json, status: :unauthorized
      end
    end
  end
end
