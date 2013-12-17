shared_examples 'notable' do

  # use, create (class_with_note has to have an ID)
  let(:class_with_note) { FactoryGirl.create("valid_#{described_class.name.underscore}".to_sym) }

  context 'associations' do
    context 'has_many' do 
      specify 'notes' do
        expect(class_with_note).to respond_to(:notes) # tests that the method notations exists
        expect(class_with_note.notes).to have(0).things
      end
    end
  end

  specify 'adding a note works' do
    expect(class_with_note.save).to be_true
    expect(class_with_note.notes << FactoryGirl.build(:note, text: 'foo')).to be_true
    expect(class_with_note.save).to be_true
    expect(class_with_note.notes).to have(1).things
    expect(class_with_note.notes[0].text).to eq('foo')
  end

  #  specify 'has many citations - includes creating a citation' do

  #   expect(class_with_note.citations.to_a).to eq([]) # there are no citations yet.

  #   expect(class_with_note.citations << FactoryGirl.build(:citation, source: FactoryGirl.create(:valid_bibtex_source))).to be_true
  #   expect(class_with_note.citations).to have(1).things
  #   expect(class_with_note.save).to be_true

  context 'methods' do
    specify 'has_notes?' do
      expect(class_with_note.has_notes?).to eq(false)
    end
  end

  specify 'prevent notes attached to housekeeping fields'
  specify 'prevent notes attached to restrited_columns'

end

