class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.unscoped.find_by(username: session_params[:username])

    if user && user.authenticate(session_params[:password])
      session[:user_id] = user.id
      if params[:remember_me]
        cookies.signed[:user_id] = {
          value: user.id,
          expires: 2.weeks.from_now,
        }
      end

      redirect_to "/"
    else
      create_failed
    end
  end

  private def create_failed
    flash.now[:danger] = "Invalid login"
    render :new, status: :unauthorized
  end

  def destroy
    reset_session
    cookies.delete(:user_id)

    redirect_to "/"
  end

  private

  def session_params
    params.permit(:username, :password)
  end

  def authenticate
  end
end
