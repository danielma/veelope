class BankAccountsController < ApplicationController
  def index
    @bank_accounts = BankAccount.all
  end

  def edit
    @bank_account = BankAccount.find(params[:id])
  end

  def update
    @bank_account = BankAccount.find(params[:id])

    if @bank_account.update(bank_account_params)
      flash[:success] = "#{@bank_account.name} updated"
      redirect_to bank_accounts_url
    else
      render :edit
    end
  end

  private

  def bank_account_params
    params.require(:bank_account).permit(:initial_balance_cents)
  end
end
