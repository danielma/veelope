module API
  module V1
    class OFXsController < ApplicationController
      def create
        render json: BankAccount.first
      end
    end
  end
end
