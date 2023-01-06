require "test_helper"

class OwnerSessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get owner_sessions_new_url
    assert_response :success
  end

  test "should get create" do
    get owner_sessions_create_url
    assert_response :success
  end

  test "should get destroy" do
    get owner_sessions_destroy_url
    assert_response :success
  end
end
