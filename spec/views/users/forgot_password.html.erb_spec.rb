require 'rails_helper'

describe 'users/forgot_password', :type => :view do
        
  it 'renders the email password reset form' do
    render
    
    assert_select 'form', nil, 1 do
      assert_select '[method=post][action=?]', '/send_password_reset'
      assert_select 'input[type=?]', 'submit', 1 do
        assert_select '[value=?]', 'Send e-mail'
      end
    end
    
    assert_select 'label[for=?]', 'email', 1
    
    assert_select 'input[id=?]', 'email', 1 do
      assert_select '[type=?]', 'text'
      assert_select '[name=?]', 'email'  
    end
  end
  
end
