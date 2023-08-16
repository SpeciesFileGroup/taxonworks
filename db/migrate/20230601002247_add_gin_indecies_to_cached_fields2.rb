class AddGinIndeciesToCachedFields2 < ActiveRecord::Migration[6.1]
  def change
    execute('CREATE INDEX tn_cached_original_gin_trgm ON taxon_names USING GIN (cached_original_combination gin_trgm_ops);')
    execute('CREATE INDEX tn_cached_auth_year_gin_trgm ON taxon_names USING GIN (cached_author_year gin_trgm_ops);')
  end
end
