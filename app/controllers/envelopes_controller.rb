class EnvelopesController < ApplicationController
  # GET /envelopes
  def index
    @envelope_groups = EnvelopeGroup.all.includes(:envelopes)
  end

  # GET /envelopes/1
  def show
    @envelope = Envelope.find(params[:id])
    @bank_transactions = @envelope.
      bank_transactions.
      includes(:bank_account, :envelopes).
      page(params[:page])
    @envelopes = Envelope.all.includes(:envelope_group)
  end

  # GET /envelopes/new
  def new
    @envelope = Envelope.new
  end

  # GET /envelopes/1/edit
  def edit
    @envelope = Envelope.find(params[:id])
  end

  # POST /envelopes
  def create
    @envelope = Envelope.new(envelope_params)

    if @envelope.save
      redirect_to @envelope, notice: 'Envelope was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /envelopes/1
  def update
    @envelope = Envelope.find(params[:id])

    if @envelope.update(envelope_params)
      redirect_to @envelope, notice: 'Envelope was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /envelopes/1
  def destroy
    @envelope = Envelope.find(params[:id])
    @envelope.destroy
    redirect_to envelopes_url, notice: 'Envelope was successfully destroyed.'
  end

  private

    # Only allow a trusted parameter "white list" through.
    def envelope_params
      params.require(:envelope).permit(:account_id, :envelope_group_id, :name)
    end
end
