module Api::V1
  class SessionsController < ApiV1Controller
    skip_action: :authorize, only: [:create]

    # POST /login
    def create
      @user = User.find_by(email: params[:user][:email])
        .try(:authenticate, params[:user][:password])
      if @user
        set_session
        render json: user_json, status: :created
      else
        render json: user_json, status: :unauthorized
      end
    end

    # GET /check_logged_in
    def check_logged_in
      render json: user_json, status: :ok
    end

    # DELETE /logout
    def logout
      cookies.delete("_tweetvine")
    end
  end
end
