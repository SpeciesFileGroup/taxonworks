require_relative 'soft_validation_helpers'

describe 'SoftValidation', group: :soft_validation do

  context 'subclass overiding methods' do
    before do
      OtherSofty.define_method(:my_sv) do
        2
      end

      Softy.define_method(:my_sv) do
        1
      end

      Softy.soft_validate(:my_sv, name: 'Check for cheeze')
      OtherSofty.soft_validate(:my_sv, name: 'Check for cheeze with microscope')
    end

    after :all do  
      Softy.send(:reset_soft_validation!)
      OtherSofty.send(:reset_soft_validation!)
      OtherOtherSofty.send(:reset_soft_validation!)
    end

    specify 'subclass overrides 1' do
      expect(Softy.soft_validation_methods[:my_sv].name).to eq('Check for cheeze')
    end

    specify 'subclass overrides 2' do
      expect(OtherSofty.soft_validation_methods[:my_sv].name).to eq('Check for cheeze with microscope')
    end

    specify 'subclass does not override 3' do
      expect(OtherOtherSofty.soft_validation_methods[:my_sv].name).to eq('Check for cheeze')
    end
  end

  context 'extended class methods' do
    specify '.has_self_soft_validations?' do
      expect(Softy.has_self_soft_validations?).to be_falsey
    end

    specify '.soft_validation_methods' do
      expect(Softy.soft_validation_methods).to eq({})
    end

      specify '.soft_validators() returns individual methods from soft_validation_methods' do
        expect(Softy.soft_validators).to eq([])
      end

      specify '.soft_validation_descriptions returns name and description pairs' do
        expect(Softy.soft_validation_descriptions).to eq({})
      end

    context 'adding soft validations' do
      before(:each) { Softy.send(:reset_soft_validation!) }

      specify 'basic use: soft_validate(:method) 1' do
        Softy.soft_validate(:haz_cheezburgers?)
        expect(Softy.soft_validation_methods.keys).to contain_exactly(:haz_cheezburgers?)
      end

      specify '#soft_validation_methods_on_self' do
        Softy.soft_validate(:haz_cheezburgers?)
        expect(Softy.soft_validation_methods_on_self).to contain_exactly(:haz_cheezburgers?)
      end

      specify 'can be assigned to a set' do
        Softy.soft_validate(:needs_moar_cheez?, set: :cheezy)
        expect(Softy.soft_validation_sets['Softy'][:cheezy]).to contain_exactly(:needs_moar_cheez?)
      end

      specify 'can be assigned a description' do
        d = 'Open bun, look for cheeze.'
        Softy.soft_validate(:needs_moar_cheez?, name: 'Check for cheeze', description: d )
        expect(Softy.soft_validation_methods[:needs_moar_cheez?].description).to eq(d)
      end

      specify 'can be assigned a resolution (path)' do
        Softy.soft_validate(:needs_moar_cheez?, name: 'Check for cheeze', resolution: [:root_path])
        expect(Softy.soft_validation_methods[:needs_moar_cheez?].resolution).to contain_exactly(:root_path)
      end

      specify 'can be asigned a fix' do
        Softy.soft_validate(:needs_moar_cheez?, name: 'Check for cheeze', fix: :my_fix)
        expect(Softy.soft_validation_methods[:needs_moar_cheez?].fixable?).to eq(true)
      end
    end

    context '#fix and :fixable' do
      before(:each) do
        Softy.send(:reset_soft_validation!)
        Softy.soft_validate(:needs_moar_cheez?, name: 'Check for cheeze')
        Softy.soft_validate(:needs_less_cheez?, name: 'Too much cheeze', fix: :remove_cheeze)
      end

      specify '.soft_validators default are all' do
        expect(Softy.soft_validators).to contain_exactly(:needs_moar_cheez?, :needs_less_cheez?)
      end

      specify '.soft_validators, fixable_only' do
        expect(Softy.soft_validators(fixable: true)).to contain_exactly(:needs_less_cheez?)
      end

      specify '.soft_validators false is all' do
        expect(Softy.soft_validators(fixable: false)).to contain_exactly(:needs_moar_cheez?)
      end
    end

    context 'soft_validations between classes' do
      before(:each) {
        Softy.send(:reset_soft_validation!)
        OtherSofty.send(:reset_soft_validation!)
      }

      specify 'methods assigned to parent are available to child' do
        Softy.soft_validate(:yucky_cheezburgers?)
        expect(OtherSofty.soft_validators).to include(:yucky_cheezburgers?)
      end

      specify 'methods assigned to child are not merged with parents' do
        OtherSofty.soft_validate(:haz_cheezburgers?)
        expect(Softy.soft_validation_sets['Softy'][:default]).to contain_exactly()
      end

      context 'accessed via soft_validators' do
        specify 'soft_validator returns a single instance of the method when method assigned to parent' do
          Softy.soft_validate(:haz_cheezburgers?)
          expect(Softy.soft_validators).to contain_exactly(:haz_cheezburgers?)
          expect(OtherSofty.soft_validators).to contain_exactly(:haz_cheezburgers?)
        end

        specify 'soft_validator returns a single instance of the method when method assigned to child' do
          OtherSofty.soft_validate(:haz_cheezburgers?)
          expect(Softy.soft_validators).to contain_exactly()
          expect(OtherSofty.soft_validators).to contain_exactly(:haz_cheezburgers?)
        end
      end
    end
  end

  context 'extended instance methods' do
    let(:softy) {Softy.new}

    specify 'soft_validate' do
      expect(softy).to respond_to(:soft_validate)
    end

    specify 'soft_valid?' do
      expect(softy).to respond_to(:soft_valid?)
    end

    specify 'clear_soft_validations' do
      expect(softy).to respond_to(:clear_soft_validations)
    end

    specify 'fix_soft_validations' do
      expect(softy).to respond_to(:fix_soft_validations)
    end
  end

  specify '.reset_soft_validation' do
    Softy.soft_validate(:just_bun?)
    Softy.send(:reset_soft_validation!)
    expect(Softy.soft_validation_sets).to eq( 'Softy' => {default: []})
    expect(Softy.soft_validation_methods).to eq( {} )
  end

  context 'example usage' do
    before { Softy.send(:reset_soft_validation!) }

    context 'with a validation that has resolution' do
      before do
        Softy.soft_validate(:just_bun?, resolution: [:root_path])
        Softy.soft_validate(:needs_moar_cheez?)
      end

      let(:softy) {Softy.new}

      specify 'soft_validations#resolution_for()' do
        expect(softy.soft_validations.resolution_for(:just_bun?)).to contain_exactly(:root_path)
      end

      specify 'soft_validations#resolution_for()' do
        expect(softy.soft_validations.resolution_for(:needs_moar_cheez?)).to contain_exactly()
      end
    end

    context 'with a validation instance that is resolvable' do
      before { Softy.soft_validate(:you_do_it?, resolution: [:root_path]) }
      let(:softy) {Softy.new}
      specify 'after validation resolution is available' do
        softy.soft_validate
          expect(softy.soft_validations.soft_validations.first.resolution).to contain_exactly(:root_path)
        end
      end

    context 'with a validation instance that is fixable' do
      before { Softy.soft_validate(:you_do_it?, fix: :my_fix) }
      let(:softy) {Softy.new}

      specify 'after validation fix is available' do
        softy.soft_validate
        expect(softy.soft_validations.soft_validations.first.fix).to eq(:my_fix)
      end
    end

    context 'with a couple of validations' do
      before do
        Softy.soft_validate(:needs_moar_cheez?, set: :cheezy)
        Softy.soft_validate(:haz_cheezburgers?, fix: :cook_cheezburgers)
      end

      let(:softy) {Softy.new}

      specify '.has_self_soft_validations?' do
        expect(Softy.has_self_soft_validations?).to be_truthy
      end

      specify 'softy.soft_valid?' do
        expect(softy.soft_valid?).to be_falsey
      end

      specify 'softy.soft_valid?' do
        expect(softy.soft_valid?).to be_falsey
      end

      specify 'softy.soft_validated?' do
        expect(softy.soft_validated?).to be_falsey
        softy.soft_validate
        expect(softy.soft_validated?).to be_truthy
      end

      context 'instances after soft_validate' do
        let(:softy) { Softy.new }

        before(:each) {
          softy.soft_validate
        }

        specify 'softy.soft_validations' do
          expect(softy.soft_validations.class).to eq(::SoftValidation::SoftValidations)
        end

        specify '#fixes_run? 1' do
          expect(softy.soft_validations.fixes_run?).to eq(false)
        end

        specify '#on' do
          expect(softy.soft_validations.on(:mohr).size).to eq(1)
        end

        specify '#fix_soft_validations' do
          expect(softy.fix_soft_validations).to be_truthy
        end

        specify '#fixes_run? 2' do
          softy.fix_soft_validations
          expect(softy.soft_validations.fixes_run?).to eq(true)
        end

        specify '#fix_messages' do
          softy.fix_soft_validations
          expect(softy.soft_validations.fix_messages).to eq({:base=>["'hungry!' was fixed (no result message provided)"], :mohr=>["no fix available"]})
        end

        specify '#messages' do
          softy.fix_soft_validations
          expect(softy.soft_validations.messages).to contain_exactly('hungry (for cheez)!', 'hungry!' )
        end

        specify '#messages_on' do
          softy.fix_soft_validations
          expect(softy.soft_validations.messages_on(:mohr)).to eq(['hungry (for cheez)!'] )
        end

        #  specify 'softy.fix_soft_validations(:requested) 4' do
        #    expect(softy.soft_validations.fix_messages).to eq(mohr: ['no fix available'], base: ['fix available, but not triggered']) # flagged
        #  end

      end
    end
  end
end
