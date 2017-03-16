class TransfersController < ApplicationController
  def new
    @transfer = Transfer.new
  end

  def create
    @transfer = Transfer.new(transfer_params)

    if @transfer.save
      flash[:success] = "Transfer created"
      redirect_to root_url
    else
      render :new
    end
  end

  private

  def transfer_params
    params.require(:transfer).permit(:from_envelope_id, :to_envelope_id, :amount_cents)
  end
end
