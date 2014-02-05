shared_examples 'notable' do

  let(:class_with_note) { FactoryGirl.build("valid_#{described_class.name.tableize.singularize.gsub('/', '_')}".to_sym) }

  context 'foo', a: :b do
    it "has access to methods defined in shared context" do
      expect(shared_method).to eq("it works")
    end

    it "has access to methods defined with let in shared context" do
      expect(shared_let['arbitrary']).to eq('object')
    end

    it "runs the before hooks defined in the shared context" do
      expect(@some_var).to be(:some_value)
    end

    it "accesses the subject defined in the shared context" do
      expect(subject).to eq('this is the subject')
    end 
  end 

  context 'reflections / foreign keys' do
    specify 'has many notes' do
      expect(class_with_note).to respond_to(:notes) # tests that the method notations exists
      expect(class_with_note.notes.count == 0).to be_true # currently has no notes
    end

    specify 'adding a object note works' do
      expect(class_with_note.save).to be_true
      expect(class_with_note.notes << FactoryGirl.build(:note, text: 'foo')).to be_true
      expect(class_with_note.save).to be_true
      expect(class_with_note.notes.count == 1).to be_true
      expect(class_with_note.notes[0].text).to eq('foo')
    end
    specify 'adding a attribute (column) note works' do
      expect(class_with_note.save).to be_true
      expect(class_with_note.notes << FactoryGirl.build(
          :note, text: 'foo', note_object_attribute: described_class.columns[1].name)).to be_true
      expect(class_with_note.save).to be_true
      expect(class_with_note.notes.count == 1).to be_true
      expect(class_with_note.notes[0].text).to eq('foo')
      expect(class_with_note.notes[0].note_object_attribute).to eq(described_class.columns[1].name)
    end

    context 'can not add note to housekeeping columns' do
      before (:each) {
        @bad_note = FactoryGirl.build(:note, text: 'foo')
        expect(class_with_note.save).to be_true
        expect(class_with_note.notes.count == 0).to be_true
        @error_message = 'can not add a note to this attribute (column)'
      }

      # for each column in ::NON_ANNOTATABLE_COLUMNS test that you can't add a note to it.
      ::NON_ANNOTATABLE_COLUMNS.each do |attr|
        specify "can not add a note to #{attr.to_s}" do
          @bad_note.note_object_attribute = attr
          @bad_note.text                  = "note to #{attr.to_s}"
          expect(class_with_note.notes << @bad_note).to be_false
          expect(class_with_note.notes.count == 0).to be_true
          expect(@bad_note.errors.messages[:note_object_attribute].include?(@error_message)).to be_true
          # now add note to a different column
          @bad_note.note_object_attribute = described_class.columns[1].name
          expect(@bad_note.errors.full_messages.include?(@error_message)).to be_false
        end
      end
    end

    specify 'can not add a note to a non-existent attribute (column)' do
      expect(class_with_note.save).to be_true
      expect(class_with_note.notes.count == 0).to be_true
      bad_note = FactoryGirl.build(:note, text: 'foo')

      bad_note.note_object_attribute = 'nonexistentColumn'
      expect(class_with_note.notes << bad_note).to be_false
      expect(class_with_note.notes.count == 0).to be_true
      expect(bad_note.errors.messages[:note_object_attribute].include?('not a valid attribute (column)')).to be_true
      # now add note to a different column
      bad_note.note_object_attribute = described_class.columns[1].name
      expect(bad_note.errors.full_messages.include?(@error_message)).to be_false
    end
  end

  context 'methods' do
    specify 'has_notations?' do
      expect(class_with_note.has_notations?).to eq(false)
    end
  end

  # specify 'prevent notes attached to restricted_columns'

end

