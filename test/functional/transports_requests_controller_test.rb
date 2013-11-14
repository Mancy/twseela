require 'test_helper'

class TransportsRequestsControllerTest < ActionController::TestCase
  setup do
    @transports_request = transports_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transports_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transports_request" do
    assert_difference('TransportsRequest.count') do
      post :create, transports_request: @transports_request.attributes
    end

    assert_redirected_to transports_request_path(assigns(:transports_request))
  end

  test "should show transports_request" do
    get :show, id: @transports_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transports_request.to_param
    assert_response :success
  end

  test "should update transports_request" do
    put :update, id: @transports_request.to_param, transports_request: @transports_request.attributes
    assert_redirected_to transports_request_path(assigns(:transports_request))
  end

  test "should destroy transports_request" do
    assert_difference('TransportsRequest.count', -1) do
      delete :destroy, id: @transports_request.to_param
    end

    assert_redirected_to transports_requests_path
  end
end
