require 'test_helper'

class HoshinsControllerTest < ActionController::TestCase
  
  def setup
    login_as :one
  end
  
  test "should get hoshin one" do
    hoshin = hoshins(:one)
    get :show, {id: hoshin.id}
    assert_response :success
    assert_equal assigns(:this), hoshin
  end
  
  test "creates hoshin" do
    login_as :one
    company = companies(:one)
    params = {name: 'hoshin-name', company_id: company.id, header: 'hoshin-header'}
    assert_difference('Hoshin.count') do      
       post :create, :hoshin => params 
    end
  end
end
