require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase
  
  def setup
    login_as :one
  end
  
  test "should get company one" do
    company = companies(:one)
    get :show, {id: company.id}
    assert_response :success
    assert_equal assigns(:this), company
  end
  
  test "creates company" do
    params = {name: 'company-name'}
    assert_difference('Company.count') do
       post :create, :company => params 
    end
  end
end
