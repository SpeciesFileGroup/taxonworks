shared_examples 'DELETE #destroy' do |klass|
  describe 'DELETE #destroy' do
    let!(:instance) { klass.create! valid_attributes }
  
    subject do
      delete :destroy, params: {id: instance.to_param}, session: valid_session
    end

    it "destroys the requested #{klass.model_name.singular}" do
      expect {subject}.to change(klass, :count).by(-1)
    end

    it "redirects to the #{klass.model_name.plural} list" do
      index_url = send("#{klass.model_name.route_key}_url")
      request.env['HTTP_REFERER'] = index_url
      expect(subject).to redirect_to(index_url)
    end
  end
end