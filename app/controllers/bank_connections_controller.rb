class BankConnectionsController < ApplicationController
  def index
    @bank_connections = BankConnection.all
  end

  def show
    @bank_connection = BankConnection.find(params[:id])
  end

  def new
  end

  def refresh
    bank_connection = BankConnection.find(params[:id]).tap(&:refresh)

    flash[:info] = "Refreshing connection now"
    redirect_to bank_connection_url(bank_connection)
  end

  def create
    connection = BankConnection.from_plaid_public_token(params[:public_token])

    connection.save!
    connection.refresh

    redirect_to bank_connections_url, flash: { success: "Connected!" }
  end

  def destroy
    bank_connection = BankConnection.find(params[:id])

    bank_connection.destroy!

    flash[:success] = "Removed bank connection"
    redirect_to bank_connections_url
  end
end
