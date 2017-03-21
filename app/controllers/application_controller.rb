class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  set_current_tenant_through_filter
  before_action :authenticate
  before_action :ensure_time_zone
  before_action :finish_onboarding
  before_action :set_refreshing_connections

  attr_reader :current_user

  private

  helper_method :return_to_path
  helper_method :current_user

  def return_to_path
    params[:return_to].presence
  end

  def authenticate
    if session[:user_id]
      authenticate_with_session
    elsif cookies.signed[:user_id]
      authenticate_with_cookie
    else
      flash[:info] = "Please login"
      redirect_to new_session_url
    end
  end

  def authenticate_with_session
    @current_user = User.unscoped.find(session[:user_id])
    set_current_tenant(current_user.account)
  rescue
    @current_user = nil
    set_current_tenant nil
    reset_session

    redirect_to root_url
  end

  def authenticate_with_cookie
    @current_user = User.unscoped.find(cookies.signed[:user_id])
    session[:user_id] = cookies.signed[:user_id]
    set_current_tenant(current_user.account)
  rescue
    @current_user = nil
    set_current_tenant nil
    cookies.delete :user_id

    redirect_to root_url
  end

  def finish_onboarding
    return if ActsAsTenant.current_tenant.blank?
    return if ActsAsTenant.current_tenant.onboarded?

    case ActsAsTenant.current_tenant.onboarding_step
    when :time_zone
      return if self.class == AccountsController

      flash[:info] = "Welcome to veelope! Please set your time zone"
      redirect_to edit_account_url
    when :create_connection
      return if self.class == BankConnectionsController

      flash.now[:info] = "Get started with veelope by " \
                         "<a href='#{bank_connections_url}'>connecting to your bank</a>"
    end
  end

  def ensure_time_zone
    Time.zone = ActsAsTenant.current_tenant.try(:time_zone)
  end

  def set_refreshing_connections
    return unless current_user

    connections = BankConnection.candidate_for_refresh

    @refreshing_connections = connections.presence

    Rails.logger.fatal("refresh #{connections.map(&:inspect)}")
    connections.map(&:refresh)
  end
end
