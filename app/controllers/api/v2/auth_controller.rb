module Api::V2
  class AuthController < ApiV2Controller
    skip_before_action :authorized, only: [:create]

    # POST /login
    def create
      @user = User.find_by(email: params[:user][:email]).try(:authenticate, params[:user][:password])
      if @user && @token = encode_token({ user_id: @user.id })
        render json: user_jwt, status: :accepted
      else
        render json: user_jwt, status: :unauthorized
      end
    end

    # GET /check_logged_in
    def check_logged_in
      if @user && @token = encode_token({ user_id: @user.id })
        render json: user_jwt, status: :ok
      else
        render json: user_jwt, status: :unauthorized
      end
    end
  end
end
