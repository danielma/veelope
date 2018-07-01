# frozen_string_literal: true

module API
  module V1
    class BankAccountOFXsController < ApplicationController
      def create
        ofx = VeelopeOFX.new(params[:file], bank_account: bank_account)

        BankTransaction.transaction do
          ofx.transactions.each do |transaction|
            transaction.to_bank_transaction.save!
          end
        end

        head :created
      end

      private

      def bank_account
        @bank_account ||= BankAccount.find(params[:bank_account_id])
      end
    end
  end
end
