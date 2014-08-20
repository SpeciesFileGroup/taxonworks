require 'rails_helper'

describe 'taxon_names/index', :type => :view do
  before(:each) do
    @taxon_names = assign(:taxon_names,
                          [stub_model(TaxonName,
                                      :name                         => 'Name',
                                      :parent_id                    => 1,
                                      :cached_name                  => 'Cached Name',
                                      :cached_author_year           => 'Cached Author Year',
                                      :cached_higher_classification => 'Cached Higher Classification',
                                      :source_id                    => 4,
                                      :year_of_publication          => 5,
                                      :verbatim_author              => 'Verbatim Author',
                                      :rank_class                   => 'Rank Class',
                                      :type                         => 'Type',
                                      :created_by_id                => 6,
                                      :updated_by_id                => 7,
                                      :project_id                   => 8,
                                      :cached_original_combination  => 'Cached Original Combination',
                                      :cached_secondary_homonym     => 'Cached Secondary Homonym',
                                      :cached_primary_homonym       => 'Cached Primary Homonym',
                                      :cached_secondary_homonym_alt => 'Cached Secondary Homonym Alt',
                                      :cached_primary_homonym_alt   => 'Cached Primary Homonym Alt'
                           ),
                           stub_model(TaxonName,
                                      :name                         => 'Name',
                                      :parent_id                    => 1,
                                      :cached_name                  => 'Cached Name',
                                      :cached_author_year           => 'Cached Author Year',
                                      :cached_higher_classification => 'Cached Higher Classification',
                                      :source_id                    => 4,
                                      :year_of_publication          => 5,
                                      :verbatim_author              => 'Verbatim Author',
                                      :rank_class                   => 'Rank Class',
                                      :type                         => 'Type',
                                      :created_by_id                => 6,
                                      :updated_by_id                => 7,
                                      :project_id                   => 8,
                                      :cached_original_combination  => 'Cached Original Combination',
                                      :cached_secondary_homonym     => 'Cached Secondary Homonym',
                                      :cached_primary_homonym       => 'Cached Primary Homonym',
                                      :cached_secondary_homonym_alt => 'Cached Secondary Homonym Alt',
                                      :cached_primary_homonym_alt   => 'Cached Primary Homonym Alt'
                           )
                          ]
    )
  end

  it 'has certain links' do
    render
  end
end
