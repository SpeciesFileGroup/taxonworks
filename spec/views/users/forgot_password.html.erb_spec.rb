require 'rails_helper'

describe 'users/forgot_password', :type => :view do
        
  it 'renders the email password reset form' do
    render
    
    assert_select 'form[id=?]', 'forgot_password', 1 do
      assert_select '[method=post][action=?]', '/user/forgot_password'
    end
    
    assert_select 'label[for=?]', 'email', 1
    
    assert_select 'input[id=?]', 'email', 1 do
      assert_select '[type=?]', 'text'
      assert_select '[name=?]', 'email'  
    end
  end
  
end
