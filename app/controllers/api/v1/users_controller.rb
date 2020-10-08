module Api::V1
  class UsersController < ApiV1Controller
    skip_before_action :authorize, only: [:create]

    # POST /signup
    def create
      if @user = User.create(params.require(:user).permit(:email, :password, :name))
        set_session
        render json: user_json, status: :created
      else
        render json: user_json, status: :not_acceptable
      end
    end

    # PATCH /change_name
    def change_name
      user = @user
      if user.authenticate(params[:user][:password]) &&
        user.update(name: params[:user][:new_name])
          @user = user
          render json: user_json, status: :ok
      else
        @user = user
        @errors = @user.errors.full_messages[0] ? @user.errors.full_messages :
          ['Unable to change name.']
        render json: user_json, status: :not_acceptable
      end
    end

    # PATCH /change_email
    def change_email
      user = @user
      if user.authenticate(params[:user][:password]) &&
        user.update(email: params[:user][:new_email])
          render json: user_json, status: :ok
      else
        @user = user
        @errors = @user.errors.full_messages[0] ? @user.errors.full_messages :
          ['Unable to update email.']
        render json: user_json, status: :not_acceptable
      end
    end

    # PATCH /change_password
    def change_password
      user = @user
      if user.authenticate(params[:user][:old_password]) &&
        !user.authenticate(params[:user][:new_password]) &&
          user.update(password: params[:user][:new_password])
            @user = user
            render json: user_json, status: :ok
      else
        @user = user
        @errors = @user.errors.full_messages[0] ? @user.errors.full_messages :
          ['Unable to update password.']
        render json: user_json, status: :not_acceptable
      end
    end

    # DELETE /delete_account
    def destroy
      @user.destroy
      cookies.delete("_biblio")
    end
  end
end
