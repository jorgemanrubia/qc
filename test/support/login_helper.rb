module LoginHelper
  def do_login(user_id, access_token)
    type_when_prompted user_id, access_token do
      run_command 'qc login'
    end
  end

  def sign_in
    do_login TestUser::USER_ID, TestUser::ACCESS_TOKEN
  end

  def assert_ask_for_login
    assert_match(/Please do login by executing 'qc login' first/, last_command.output)
  end
end
