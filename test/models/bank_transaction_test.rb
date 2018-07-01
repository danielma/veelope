# frozen_string_literal: true

require "test_helper"

class BankTransactionTest < ActiveSupport::TestCase
  include AssertValidFixtures

  test ".candidate_for_merge" do
    candidates = described_class.candidate_for_merge

    assert { candidates.length == 1 }
    assert { candidates.include? bank_transactions(:west_vons_needs_merge) }
  end

  test ".merge prefers remote, and can move designations in" do
    original = bank_transactions(:west_vons_needs_merge)
    candidate = bank_transactions(:west_vons)
    @designations = Designation.where(id: candidate.designations.pluck(:id))

    assert_difference "BankTransaction.unscoped.count", -1 do
      assert_changes "@designations.reload.map(&:bank_transaction).uniq", to: [original] do
        described_class.merge(candidate, original)
      end
    end

    assert_raises(ActiveRecord::RecordNotFound) { candidate.reload }
    assert { original.reload.present? }
  end

  test ".merge in other direction" do
    original = bank_transactions(:west_vons_needs_merge)
    candidate = bank_transactions(:west_vons)

    assert_difference "BankTransaction.unscoped.count", -1 do
      described_class.merge(original, candidate)
    end

    assert_raises(ActiveRecord::RecordNotFound) { candidate.reload }
    assert { original.reload.present? }
  end

  test ".merge returns an error if both have designations" do
    candidate = bank_transactions(:west_vons_needs_merge)
    candidate.designations.create!(envelope: envelopes(:groceries))

    original = bank_transactions(:west_vons)

    result = assert_no_difference "BankTransaction.unscoped.count" do
      described_class.merge(original, candidate)
    end

    assert { result.is_a? described_class::MergeError }
    assert { result.message =~ /designations/i }
  end

  test ".merge returns an error if transactions are not candidates for merge" do
    original = bank_transactions(:west_vons)
    candidate = bank_transactions(:west_undesignated)

    result = assert_no_difference "BankTransaction.unscoped.count" do
      described_class.merge(candidate, original)
    end

    assert { result.is_a? described_class::MergeError }
    assert { result.message =~ /candidate/i }
  end
end
