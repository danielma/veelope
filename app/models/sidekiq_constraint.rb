class SidekiqConstraint
  def matches?(request)
    return true if AppConfig.sidekiq.allow_all

    user = User.unscoped.find_by(id: request.session[:user_id])
    user ? user.username == AppConfig.sidekiq.super_username : false
  end
end
