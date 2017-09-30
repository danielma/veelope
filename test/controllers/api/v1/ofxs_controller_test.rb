require "test_helper"

module API
  module V1
    class OFXsControllerTest < ActionDispatch::IntegrationTest
      setup :login

      test "import" do
        post api_v1_ofxs_url

        ap JSON.parse(response.body)
      end
    end
  end
end
