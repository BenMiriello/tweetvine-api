class AuthController < ApiV2Controller
  skip_before_action :authorized, only: [:create]

  # POST /login
  def create
    @user = User.find_by(email: params[:user][:email])
      .try(:authenticate, params[:user][:password])
    if @user
      render json: user_jwt, status: :created
    else
      render json: user_jwt, status: :unauthorized
    end
  end

  # GET /check_logged_in
  def check_logged_in
    render json: user_jwt, status: :ok
  end

  # DELETE /logout
  def logout
    # cookies.delete("_tweetvine")
  end
end
