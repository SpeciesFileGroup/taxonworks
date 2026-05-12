require 'rails_helper'

describe Utilities::MaterialExamined do

  def rec(overrides = {})
    {
      'typeStatus'      => 'paratype',
      'country'         => 'United States',
      'stateProvince'   => 'Illinois',
      'county'          => 'Champaign',
      'month'           => '7',
      'institutionCode' => 'INHS',
      'catalogNumber'   => 'INHS 714075',
      'individualCount' => '1',
      'lifeStage'       => 'Adult',
      'sex'             => 'male',
      'occurrenceID'    => 'r1'
    }.merge(overrides)
  end

  def render(*records, **kwargs)
    Utilities::MaterialExamined.new(records, **kwargs).render
  end

  # ---------------------------------------------------------------------------
  # Default order — single record, all fields present
  # ---------------------------------------------------------------------------
  describe 'default order' do
    let(:base) { rec }

    specify 'single record' do
      expect(render(base)).to eq(
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: vii, 1 INHS 714075 **Adult** **♂**: (INHS)'
      )
    end

    # ---- second record: catalog number in range (+1) ----
    context 'second record in range (+1), same attributes' do
      let(:r2) { rec('catalogNumber' => 'INHS 714076', 'occurrenceID' => 'r2') }

      specify 'collapses to identifier range, sums individualCount' do
        expect(render(base, r2)).to eq(
          '**PARATYPE** (2) **United States**: **Illinois**: **Champaign**: vii, 2 INHS 714075-6 **Adult** **♂**: (INHS)'
        )
      end

      context 'second record has individualCount 6' do
        let(:r2) { rec('catalogNumber' => 'INHS 714076', 'occurrenceID' => 'r2', 'individualCount' => '6') }

        specify 'total reflects individualCount sum, not record count' do
          expect(render(base, r2)).to eq(
            '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075-6 **Adult** **♂**: (INHS)'
          )
        end

        context 'second record has a different sex' do
          let(:r2) { rec('catalogNumber' => 'INHS 714076', 'occurrenceID' => 'r2', 'individualCount' => '6', 'sex' => 'female') }

          specify 'different sex breaks range collapse' do
            expect(render(base, r2)).to eq(
              '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 **Adult** **♂**: (INHS); INHS 714076 **Adult** **♀**: (INHS)'
            )
          end

          context 'second record has a different lifeStage' do
            let(:r2) { rec('catalogNumber' => 'INHS 714076', 'occurrenceID' => 'r2', 'individualCount' => '6', 'sex' => 'female', 'lifeStage' => 'Juvenile') }

            specify 'different stage and sex, no range collapse' do
              expect(render(base, r2)).to eq(
                '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 **Adult** **♂**: (INHS); INHS 714076 **Juvenile** **♀**: (INHS)'
              )
            end
          end
        end
      end
    end

    # ---- second record: catalog number NOT in range (+3) ----
    context 'second record NOT in range (+3), same attributes' do
      let(:r3) { rec('catalogNumber' => 'INHS 714078', 'occurrenceID' => 'r3') }

      specify 'non-consecutive identifiers are not collapsed' do
        expect(render(base, r3)).to eq(
          '**PARATYPE** (2) **United States**: **Illinois**: **Champaign**: vii, 2 INHS 714075 **Adult** **♂**: (INHS); INHS 714078 **Adult** **♂**: (INHS)'
        )
      end

      context 'second record has individualCount 6' do
        let(:r3) { rec('catalogNumber' => 'INHS 714078', 'occurrenceID' => 'r3', 'individualCount' => '6') }

        specify 'total still sums individualCount across non-consecutive identifiers' do
          expect(render(base, r3)).to eq(
            '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 **Adult** **♂**: (INHS); INHS 714078 **Adult** **♂**: (INHS)'
          )
        end

        context 'second record has a different sex' do
          let(:r3) { rec('catalogNumber' => 'INHS 714078', 'occurrenceID' => 'r3', 'individualCount' => '6', 'sex' => 'female') }

          specify 'different sex, non-consecutive identifiers' do
            expect(render(base, r3)).to eq(
              '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 **Adult** **♂**: (INHS); INHS 714078 **Adult** **♀**: (INHS)'
            )
          end

          context 'second record has a different lifeStage' do
            let(:r3) { rec('catalogNumber' => 'INHS 714078', 'occurrenceID' => 'r3', 'individualCount' => '6', 'sex' => 'female', 'lifeStage' => 'Juvenile') }

            specify 'different stage and sex, non-consecutive identifiers' do
              expect(render(base, r3)).to eq(
                '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 **Adult** **♂**: (INHS); INHS 714078 **Juvenile** **♀**: (INHS)'
              )
            end
          end
        end
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Reordered fields (using single base record)
  # ---------------------------------------------------------------------------
  describe 'reordered fields' do
    let(:base) { rec }

    specify 'type_status removed from order' do
      order = [:country, :state, :county, :month_range, :total,
               :identifier_namespace, :identifier, :stage, :sex, :repository]
      expect(render(base, order:)).to eq(
        '**United States**: **Illinois**: **Champaign**: vii, 1 INHS 714075 **Adult** **♂**: (INHS)'
      )
    end

    specify 'total before month_range' do
      order = [:type_status, :country, :state, :county, :total, :month_range,
               :identifier_namespace, :identifier, :stage, :sex, :repository]
      expect(render(base, order:)).to eq(
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: 1 vii, INHS 714075 **Adult** **♂**: (INHS)'
      )
    end

    specify 'total after identifier' do
      order = [:type_status, :country, :state, :county, :month_range,
               :identifier_namespace, :identifier, :total, :stage, :sex, :repository]
      expect(render(base, order:)).to eq(
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: vii, INHS 714075 1 **Adult** **♂**: (INHS)'
      )
    end
  end

  # ---------------------------------------------------------------------------
  # Removed fields (using single base record)
  # ---------------------------------------------------------------------------
  describe 'removed fields' do
    let(:base) { rec }

    specify 'month_range removed' do
      order = [:type_status, :country, :state, :county, :total,
               :identifier_namespace, :identifier, :stage, :sex, :repository]
      expect(render(base, order:)).to eq(
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: 1 INHS 714075 **Adult** **♂**: (INHS)'
      )
    end

    specify 'stage and sex removed' do
      order = [:type_status, :country, :state, :county, :month_range, :total,
               :identifier_namespace, :identifier, :repository]
      expect(render(base, order:)).to eq(
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: vii, 1 INHS 714075 (INHS)'
      )
    end

    specify 'identifier_namespace and identifier removed together' do
      order = [:type_status, :country, :state, :county, :month_range, :total,
               :stage, :sex, :repository]
      expect(render(base, order:)).to eq(
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: vii, 1 **Adult** **♂**: (INHS)'
      )
    end
  end

  # ---------------------------------------------------------------------------
  # Geographic alphabetic sorting
  # ---------------------------------------------------------------------------
  describe 'geographic alphabetic sorting' do
    let(:records) do
      [
        rec('country' => 'United States', 'stateProvince' => 'Illinois', 'county' => 'Ogle'),
        rec('country' => 'United States', 'stateProvince' => 'Illinois', 'county' => 'Champaign Co.', 'occurrenceID' => 'r2'),
        rec('country' => 'United States', 'stateProvince' => 'Alabama', 'county' => '', 'occurrenceID' => 'r3'),
      ]
    end

    subject(:result) do
      Utilities::MaterialExamined.new(records, order: [:country, :state, :county, :total]).render
    end

    specify 'states are sorted alphabetically within their country' do
      expect(result.index('Alabama')).to be < result.index('Illinois')
    end

    specify 'counties are sorted alphabetically within their state' do
      expect(result.index('Champaign')).to be < result.index('Ogle')
    end
  end

end
