require 'test_helper'

class TransportsPathsControllerTest < ActionController::TestCase
  setup do
    @transports_path = transports_paths(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transports_paths)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transports_path" do
    assert_difference('TransportsPath.count') do
      post :create, transports_path: @transports_path.attributes
    end

    assert_redirected_to transports_path_path(assigns(:transports_path))
  end

  test "should show transports_path" do
    get :show, id: @transports_path.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @transports_path.to_param
    assert_response :success
  end

  test "should update transports_path" do
    put :update, id: @transports_path.to_param, transports_path: @transports_path.attributes
    assert_redirected_to transports_path_path(assigns(:transports_path))
  end

  test "should destroy transports_path" do
    assert_difference('TransportsPath.count', -1) do
      delete :destroy, id: @transports_path.to_param
    end

    assert_redirected_to transports_paths_path
  end
end
