class BankTransactionsController < ApplicationController
  def index
    relation = BankTransaction.all.
      includes(:bank_account, :envelopes).
      page(params[:page])

    if params[:bank_account_id]
      relation = relation.where(bank_account_id: params[:bank_account_id])
    end

    if params[:envelope_id]
      relation = relation.
        left_outer_joins(:envelopes).
        where(envelopes: { id: params[:envelope_id] })
    end

    @bank_transactions = relation
    load_envelopes
  end

  def inbox
    relation = BankTransaction.undesignated.
      includes(:bank_account, :envelopes).
      page(params[:page])

    if params[:bank_account_id]
      relation = relation.where(bank_account_id: params[:bank_account_id])
    end

    @bank_transactions = relation
    load_envelopes

    render :index
  end

  def new
    @bank_transaction = BankTransaction.new
    load_envelopes
  end

  def create
    @bank_transaction = BankTransaction.new(bank_transaction_create_params)

    if @bank_transaction.save
      flash[:success] = "Transaction created"
      redirect_to bank_transactions_url
    else
      load_envelopes
      render :new
    end
  end

  def edit
    @bank_transaction = BankTransaction.find(params[:id])
    load_envelopes
  end

  def update
    @bank_transaction = BankTransaction.find(params[:id])

    success = @bank_transaction.update(bank_transaction_update_params)

    respond_to do |format|
      format.html { update_html(success) }
      format.json { update_json(success) }
    end
  end

  private def update_html(success)
    if success
      flash[:success] = "Transaction was updated"
      redirect_to return_to_path || bank_transactions_url
    else
      load_envelopes
      render :edit
    end
  end

  private def update_json(success)
    if success
      render json: { ok: true }
    else
      render json: { errors: @bank_transaction.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def load_envelopes
    @envelopes = Envelope.all.includes(:envelope_group)
  end

  def bank_transaction_update_params
    params.
      require(:bank_transaction).
      permit(
        :memo,
        designations_attributes: %i(id envelope_id amount_cents),
      )
  end

  def bank_transaction_create_params
    params.
      require(:bank_transaction).
      permit(
        :bank_account_id, :payee, :posted_at, :amount_cents, :memo,
        designations_attributes: %i(envelope_id amount_cents)
      ).
      tap do |p|
        p.merge!(source: "manual")
        p[:bank_account_id] ||= params[:bank_account_id]
      end
  end
end
