class VeelopeOFX
  def initialize(source, bank_account: nil)
    @ofx = OFX(source)
    @source = ofx.body
    @bank_account = bank_account
  end

  def account
    @account ||= OFXAccount.new(
      ofx.account,
      organization: organization,
      source: source,
      bank_account: bank_account,
    )
  end

  def transactions
    @transactions ||= ofx.account.transactions.map { |t| OFXTransaction.new(t, account: account) }
  end

  def organization
    @organization ||= OFXOrganization.new(ofx.sign_on)
  end

  private

  attr_reader :ofx, :source, :bank_account

  class OFXOrganization
    def initialize(sign_on)
      @sign_on = sign_on
    end

    def name
      sign_on.fi_name
    end

    private

    attr_reader :sign_on
  end
end
