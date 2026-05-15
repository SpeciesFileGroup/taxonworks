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
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: vii, 1 INHS 714075 Adult **♂**: (INHS)'
      )
    end

    # ---- second record: catalog number in range (+1) ----
    context 'second record in range (+1), same attributes' do
      let(:r2) { rec('catalogNumber' => 'INHS 714076', 'occurrenceID' => 'r2') }

      specify 'collapses to identifier range, sums individualCount' do
        expect(render(base, r2)).to eq(
          '**PARATYPE** (2) **United States**: **Illinois**: **Champaign**: vii, 2 INHS 714075-6 Adult **♂**: (INHS)'
        )
      end

      context 'second record has individualCount 6' do
        let(:r2) { rec('catalogNumber' => 'INHS 714076', 'occurrenceID' => 'r2', 'individualCount' => '6') }

        specify 'total reflects individualCount sum, not record count' do
          expect(render(base, r2)).to eq(
            '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075-6 Adult **♂**: (INHS)'
          )
        end

        context 'second record has a different sex' do
          let(:r2) { rec('catalogNumber' => 'INHS 714076', 'occurrenceID' => 'r2', 'individualCount' => '6', 'sex' => 'female') }

          specify 'different sex breaks range collapse' do
            expect(render(base, r2)).to eq(
              '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 Adult **♂**: (INHS); INHS 714076 Adult **♀**: (INHS)'
            )
          end

          context 'second record has a different lifeStage' do
            let(:r2) { rec('catalogNumber' => 'INHS 714076', 'occurrenceID' => 'r2', 'individualCount' => '6', 'sex' => 'female', 'lifeStage' => 'Juvenile') }

            specify 'different stage and sex, no range collapse' do
              expect(render(base, r2)).to eq(
                '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 Adult **♂**: (INHS); INHS 714076 Juvenile **♀**: (INHS)'
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
          '**PARATYPE** (2) **United States**: **Illinois**: **Champaign**: vii, 2 INHS 714075 Adult **♂**: (INHS); INHS 714078 Adult **♂**: (INHS)'
        )
      end

      context 'second record has individualCount 6' do
        let(:r3) { rec('catalogNumber' => 'INHS 714078', 'occurrenceID' => 'r3', 'individualCount' => '6') }

        specify 'total still sums individualCount across non-consecutive identifiers' do
          expect(render(base, r3)).to eq(
            '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 Adult **♂**: (INHS); INHS 714078 Adult **♂**: (INHS)'
          )
        end

        context 'second record has a different sex' do
          let(:r3) { rec('catalogNumber' => 'INHS 714078', 'occurrenceID' => 'r3', 'individualCount' => '6', 'sex' => 'female') }

          specify 'different sex, non-consecutive identifiers' do
            expect(render(base, r3)).to eq(
              '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 Adult **♂**: (INHS); INHS 714078 Adult **♀**: (INHS)'
            )
          end

          context 'second record has a different lifeStage' do
            let(:r3) { rec('catalogNumber' => 'INHS 714078', 'occurrenceID' => 'r3', 'individualCount' => '6', 'sex' => 'female', 'lifeStage' => 'Juvenile') }

            specify 'different stage and sex, non-consecutive identifiers' do
              expect(render(base, r3)).to eq(
                '**PARATYPE** (7) **United States**: **Illinois**: **Champaign**: vii, 7 INHS 714075 Adult **♂**: (INHS); INHS 714078 Juvenile **♀**: (INHS)'
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
        '**United States**: **Illinois**: **Champaign**: vii, 1 INHS 714075 Adult **♂**: (INHS)'
      )
    end

    specify 'total before month_range' do
      order = [:type_status, :country, :state, :county, :total, :month_range,
               :identifier_namespace, :identifier, :stage, :sex, :repository]
      expect(render(base, order:)).to eq(
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: 1 vii, INHS 714075 Adult **♂**: (INHS)'
      )
    end

    specify 'total after identifier' do
      order = [:type_status, :country, :state, :county, :month_range,
               :identifier_namespace, :identifier, :total, :stage, :sex, :repository]
      expect(render(base, order:)).to eq(
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: vii, INHS 714075 1 Adult **♂**: (INHS)'
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
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: 1 INHS 714075 Adult **♂**: (INHS)'
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
        '**PARATYPE** (1) **United States**: **Illinois**: **Champaign**: vii, 1 Adult **♂**: (INHS)'
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

  # ---------------------------------------------------------------------------
  # TODO mode
  # ---------------------------------------------------------------------------
  describe 'todo mode' do
    def render_todo(*records, **kwargs)
      Utilities::MaterialExamined.new(records, todo: true, **kwargs)
    end

    context 'blank sex field' do
      let(:r) { rec('sex' => '', 'occurrenceID' => 'r-todo-sex') }

      specify 'renders [TODO] in place of blank sex' do
        result = render_todo(r).render
        expect(result).to include('[TODO]')
      end

      specify 'populates todo_occurrence_ids' do
        renderer = render_todo(r)
        renderer.render
        expect(renderer.todo_occurrence_ids).to include('r-todo-sex')
      end
    end

    context 'blank month field' do
      let(:r) { rec('month' => '', 'eventDate' => '', 'occurrenceID' => 'r-todo-month') }

      specify 'renders [TODO] in place of blank month' do
        result = render_todo(r).render
        expect(result).to include('[TODO]')
      end

      specify 'populates todo_occurrence_ids' do
        renderer = render_todo(r)
        renderer.render
        expect(renderer.todo_occurrence_ids).to include('r-todo-month')
      end
    end

    context 'blank sex and blank month on separate records' do
      let(:r_sex)   { rec('sex' => '',    'occurrenceID' => 'r-todo-sex',   'catalogNumber' => 'INHS 1') }
      let(:r_month) { rec('month' => '',  'eventDate' => '', 'occurrenceID' => 'r-todo-month', 'catalogNumber' => 'INHS 2') }

      specify 'both [TODO] values appear in output' do
        result = render_todo(r_sex, r_month).render
        expect(result.scan('[TODO]').length).to be >= 2
      end

      specify 'both occurrence ids are collected' do
        renderer = render_todo(r_sex, r_month)
        renderer.render
        expect(renderer.todo_occurrence_ids).to include('r-todo-sex', 'r-todo-month')
      end
    end

    context 'non-todo mode leaves blank fields invisible' do
      let(:r) { rec('sex' => '', 'month' => '', 'eventDate' => '') }

      specify 'does not render [TODO]' do
        result = render(r)
        expect(result).not_to include('[TODO]')
      end
    end
  end

end
