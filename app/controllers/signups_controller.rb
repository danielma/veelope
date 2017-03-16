class SignupsController < ApplicationController
  def new
  end

  def create
    result = CreateSignup.call(signup_params)

    if result.ok?
      session[:user_id] = result.user.id

      redirect_to "/"
    elsif result.message == :invalid_secret
      head :forbidden
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def authenticate
  end

  def signup_params
    params.permit(:username, :password, :password_confirmation, :secret)
  end
end
