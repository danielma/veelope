module AssertValidFixtures
  extend ActiveSupport::Concern

  included do
    test "fixtures are valid" do
      ActsAsTenant.without_tenant do
        described_class.all.each do |fixture|
          assert_valid fixture
        end
      end
    end
  end
end
