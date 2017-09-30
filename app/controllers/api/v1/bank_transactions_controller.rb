module API
  module V1
    class BankTransactionsController < ApplicationController
      def create
        transaction = BankTransaction.new(bank_transaction_params)

        if transaction.save
          render json: transaction, status: :created
        else
          render json: transaction.errors, status: :unprocessable_entity
        end
      end

      private

      def bank_transaction_params
        params.
          require(:bank_transaction).
          permit(
            :bank_account_id, :payee, :posted_at, :amount_cents, :memo, :remote_identifier,
            designations_attributes: %i(envelope_id amount_cents)
          ).tap do |whitelisted|
          whitelisted[:source] = "manual"
        end
      end
    end
  end
end
