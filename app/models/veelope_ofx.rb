class VeelopeOFX
  def initialize(source)
    @ofx = OFX(source)
  end

  def account
    @account ||= OFXAccount.new(ofx.account, organization: organization)
  end

  def transactions
    @transactions ||= ofx.account.transactions.map { |t| OFXTransaction.new(t, account: account) }
  end

  def organization
    @organization ||= OFXOrganization.new(ofx.sign_on)
  end

  private

  attr_reader :ofx

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
