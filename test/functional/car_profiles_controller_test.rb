require 'test_helper'

class CarProfilesControllerTest < ActionController::TestCase
  setup do
    @car_profile = car_profiles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:car_profiles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create car_profile" do
    assert_difference('CarProfile.count') do
      post :create, car_profile: @car_profile.attributes
    end

    assert_redirected_to car_profile_path(assigns(:car_profile))
  end

  test "should show car_profile" do
    get :show, id: @car_profile.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @car_profile.to_param
    assert_response :success
  end

  test "should update car_profile" do
    put :update, id: @car_profile.to_param, car_profile: @car_profile.attributes
    assert_redirected_to car_profile_path(assigns(:car_profile))
  end

  test "should destroy car_profile" do
    assert_difference('CarProfile.count', -1) do
      delete :destroy, id: @car_profile.to_param
    end

    assert_redirected_to car_profiles_path
  end
end
