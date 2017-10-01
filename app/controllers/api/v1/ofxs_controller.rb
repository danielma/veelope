module API
  module V1
    class OFXsController < ApplicationController
      def create
        ofx = VeelopeOFX.new(params[:file])

        BankTransaction.transaction do
          ofx.account.to_bank_account.save!
          ofx.transactions.each do |transaction|
            transaction.to_bank_transaction.save!
          end
        end

        head :created
      end
    end
  end
end
