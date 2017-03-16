class DesignationsController < ApplicationController
  before_action :set_designation, only: [:show, :edit, :update, :destroy]

  # GET /designations
  def index
    @designations = Designation.all
  end

  # GET /designations/1
  def show
  end

  # GET /designations/new
  def new
    @designation = Designation.new
  end

  # GET /designations/1/edit
  def edit
  end

  # POST /designations
  def create
    @designation = Designation.new(designation_params)

    if @designation.save
      redirect_to @designation, notice: 'Designation was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /designations/1
  def update
    if @designation.update(designation_params)
      redirect_to @designation, notice: 'Designation was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /designations/1
  def destroy
    @designation.destroy
    redirect_to designations_url, notice: 'Designation was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_designation
      @designation = Designation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def designation_params
      params.require(:designation).permit(:account_id, :bank_transaction_id, :amount, :envelope_id)
    end
end
