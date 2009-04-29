require 'test_helper'

class BadwordsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:badwords)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create badword" do
    assert_difference('Badword.count') do
      post :create, :badword => { }
    end

    assert_redirected_to badword_path(assigns(:badword))
  end

  test "should show badword" do
    get :show, :id => badwords(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => badwords(:one).id
    assert_response :success
  end

  test "should update badword" do
    put :update, :id => badwords(:one).id, :badword => { }
    assert_redirected_to badword_path(assigns(:badword))
  end

  test "should destroy badword" do
    assert_difference('Badword.count', -1) do
      delete :destroy, :id => badwords(:one).id
    end

    assert_redirected_to badwords_path
  end
end
