class AddGinIndeciesToCachedFields < ActiveRecord::Migration[6.1]
  def change
    execute('CREATE INDEX tn_cached_gin_trgm ON taxon_names USING GIN (cached gin_trgm_ops);')
    execute('CREATE INDEX src_cached_gin_trgm ON sources USING GIN (cached gin_trgm_ops);')
    execute('CREATE INDEX ppl_cached_gin_trgm ON people USING GIN (cached gin_trgm_ops);')
  end
end
