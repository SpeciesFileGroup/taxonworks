# Factory conventions

* Factory file names are singular, and end in `_factory`
* All models need a `valid_` bot, nested within the canonical bot:

## Project specific 

Include `:housekeeping` traits

```
FactoryBot.define do
  factory :otu, traits: [:housekeeping] do
    factory :valid_otu do
      name { Faker::Lorem.word }
    end
  end
end
```

## Community/shared data

Include `:creator_and_updator` trait.

```
FactoryBot.define do
  factory :source, traits: [:creator_and_updater]  do

    factory :valid_source do
      bibtex_type { 'article' }
      title { 'article 1 just title' }
      type { 'Source::Bibtex' }
    end

    initialize_with { new(type: type) }
  end
end
```

