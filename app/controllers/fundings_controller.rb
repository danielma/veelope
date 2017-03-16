class FundingsController < ApplicationController
  def new
    @envelopes = Envelope.all.includes(:envelope_group)
    @funding = Funding.new
  end

  def create
    @funding = Funding.new(funding_params)

    if @funding.save
      flash[:success] = "Funding complete"
      redirect_to root_url
    else
      @envelopes = Envelope.all.includes(:envelope_group)
      render :new
    end
  end

  private

  def funding_params
    params.require(:funding).
      permit(designations_attributes: %i(envelope_id amount_cents))
  end
end
