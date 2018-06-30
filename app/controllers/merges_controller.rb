# frozen_string_literal: true

class MergesController < ApplicationController
  def index
    @candidates = BankTransaction.candidate_for_merge.page(params[:page])
    others = BankTransaction.where(id: @candidates.map(&:merge_candidate_id))
    @candidates.each do |candidate|
      candidate.merge_candidate = others.find { |i| i.id == candidate.merge_candidate_id }
    end
    @envelopes = Envelope.all.includes(:envelope_group)
  end

  def create
    transaction_a = BankTransaction.find(params.require(:mergeable_a))
    transaction_b = BankTransaction.find(params.require(:mergeable_b))

    result = BankTransaction.merge(transaction_a, transaction_b)

    if result.is_a?(StandardError)
      flash[:danger] = "Unable to merge: #{result.message}"
    else
      flash[:success] = "Merged!"
    end

    redirect_to merges_url
  end
end
