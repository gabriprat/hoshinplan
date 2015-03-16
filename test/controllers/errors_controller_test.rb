require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  
  test "should get file_not_found" do
    get :file_not_found
    assert_response 404
  end

  test "should get unprocessable" do
    get :unprocessable
    assert_response 422
  end

  test "should get internal_server_error" do
    get :internal_server_error
    assert_response 500
  end
  
  test "should get service_unavailable" do
    get :service_unavailable
    assert_response 503
  end

end
