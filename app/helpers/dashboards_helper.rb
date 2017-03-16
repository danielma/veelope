module DashboardsHelper
  def balance_class(balance)
    return "zero" if balance.zero?

    balance > 0 ? "positive" : "negative"
  end
end
