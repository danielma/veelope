class AccountsController < ApplicationController
  def edit
    @account = ActsAsTenant.current_tenant
  end

  def update
    @account = ActsAsTenant.current_tenant

    if @account.update(account_params)
      flash[:success] = "Updated"
    else
      flash[:info] = "Unable to update"
    end

    redirect_to edit_account_url
  end

  private

  def account_params
    params.require(:account).permit(:time_zone)
  end
end
