class EnvelopeGroupsController < ApplicationController
  before_action :set_envelope_group, only: [:show, :edit, :update, :destroy]

  # GET /envelope_groups
  def index
    @envelope_groups = EnvelopeGroup.all
  end

  # GET /envelope_groups/1
  def show
  end

  # GET /envelope_groups/new
  def new
    @envelope_group = EnvelopeGroup.new
  end

  # GET /envelope_groups/1/edit
  def edit
  end

  # POST /envelope_groups
  def create
    @envelope_group = EnvelopeGroup.new(envelope_group_params)

    if @envelope_group.save
      redirect_to @envelope_group, notice: 'Envelope group was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /envelope_groups/1
  def update
    if @envelope_group.update(envelope_group_params)
      redirect_to @envelope_group, notice: 'Envelope group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /envelope_groups/1
  def destroy
    @envelope_group.destroy
    redirect_to envelope_groups_url, notice: 'Envelope group was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_envelope_group
      @envelope_group = EnvelopeGroup.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def envelope_group_params
      params.require(:envelope_group).permit(:account_id, :name)
    end
end
