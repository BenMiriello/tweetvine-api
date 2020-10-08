module Api::V2
  class UsersController < ApiV2Controller
    skip_before_action :authorized, only: [:create]

    # POST /signup
    def create
      @user = User.create(params.require(:user).permit(:email, :password, :name))
      if @user.valid?
        @token = encode_token(user_id: @user.id)
        render json: user_jwt, status: :created
      else
        render json: user_jwt, status: :not_acceptable
      end
    end

    # PATCH /change_name
    def change_name
      user = @user
      if user.authenticate(params[:user][:password]) &&
        user.update(name: params[:user][:new_name])
          @user = user
          render json: user_jwt, status: :ok
      else
        @user = user
        errors = @user.errors.full_messages[0] ? @user.errors.full_messages :
          ['Unable to change name.']
        render json: user_jwt(errors), status: :not_acceptable
      end
    end

    # PATCH /change_email
    def change_email
      user_tmp = @user
      if user_tmp.authenticate(params[:user][:password]) &&
        user_tmp.update(email: params[:user][:new_email])
          render json: user_jwt, status: :ok
      else
        @user = user_tmp
        errors = @user.errors.full_messages[0] ? @user.errors.full_messages :
          ['Unable to update email.']
        render json: user_jwt(errors), status: :not_acceptable
      end
    end

    # PATCH /change_password
    def change_password
      user_tmp = @user
      if user_tmp.authenticate(params[:user][:old_password]) &&
        !user_tmp.authenticate(params[:user][:new_password]) &&
          user_tmp.update(password: params[:user][:new_password])
            @user = user_tmp
            render json: user_jwt, status: :ok
      else
        @user = user_tmp
        errors = @user.errors.full_messages[0] ? @user.errors.full_messages :
          ['Unable to update password.']
        render json: user_jwt(errors), status: :not_acceptable
      end
    end

    # DELETE /delete_account
    def destroy
      @user.destroy
    end
  end
end
