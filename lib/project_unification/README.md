# Project Unification

Safely merge all data from one TaxonWorks project into another.

## Overview

The Project Unification system provides a robust, transaction-safe way to consolidate data from multiple projects. It handles:

- **All project-scoped models** with varying complexity
- **Uniqueness validation conflicts** through categorized processing tracks
- **TaxonName hierarchies** with closure_tree preservation
- **Preview mode** for risk-free testing
- **Detailed reporting** of all operations

## Quick Start

### Preview Unification (Safe)

```ruby
source = Project.find(5)
target = Project.find(3)

result = target.unify(source, preview: true)
puts result[:statistics]
```

### Actual Unification

```ruby
result = target.unify(source, preview: false)

if result[:unified]
  puts "Successfully migrated #{result[:statistics][:records_migrated]} records"
else
  puts "Errors: #{result[:errors]}"
end
```

### Custom TaxonName Root

```ruby
# Merge source hierarchy under a specific taxon in target
genus = target.taxon_names.find_by(name: 'Aus')

result = target.unify(
  source,
  root_taxon_name_id: genus.id,
  preview: false
)
```

## Rake Tasks

### Unify Projects

```bash
# Preview (safe - rolls back)
rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3

# Actually perform unification
rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3 PREVIEW=false

# With custom TaxonName root
rake tw:project:unify SOURCE_PROJECT_ID=5 TARGET_PROJECT_ID=3 ROOT_TAXON_NAME_ID=123 PREVIEW=false
```

## Architecture

### Processing Tracks

Models are categorized by validation complexity:

#### Fast Track (Bulk SQL UPDATE)
- ProjectSource
- RangedLotCategory
- OtuPageLayout
- ~30 other models with simple or no uniqueness constraints

**Processing**: Single SQL UPDATE statement per model

#### Slow Track (Per-Record Processing)
- ObservationMatrix
 -ImportDataset

**Processing**: Batch iteration with validation, custom conflict handlers

#### Special Handling
- **TaxonName**: Custom hierarchy merging with closure_tree rebuild
- many others

### Module Structure

```
lib/project_unification/
├── model_classifier.rb      # Categorizes models by track
├── validator.rb              # Pre-flight conflict detection
├── migrator.rb               # Main migration orchestration
├── taxon_name_handler.rb    # TaxonName special handling
└── cached_rebuilder.rb       # Post-migration cache rebuild
```

### Data Flow

1. **Validation** (ProjectUnification::Validator)
   - SQL-based conflict detection
   - Statistics gathering
   - Warning identification

2. **Migration** (ProjectUnification::Migrator)
   - Process in MANIFEST order (dependencies first)
   - Apply track-specific strategies
   - Handle conflicts and deduplication

3. **TaxonName Handling** (ProjectUnification::TaxonNameHandler)
   - Update source root parent
   - Bulk update descendants
   - Rebuild closure_tree

4. **Cache Rebuild** (ProjectUnification::CachedRebuilder)
   - Recalculate cached fields
   - Batch processing for performance

5. **Results**
   - Detailed statistics
   - Per-model breakdowns
   - Error reporting

## Custom Conflict Handling

Models can implement custom conflict resolution:

```ruby
class MyModel < ApplicationRecord
  include Shared::ProjectUnification

  def handle_unify_conflict(target_project_id)
    # Custom logic to resolve uniqueness conflicts
    self.name = "#{name}_migrated_#{Time.now.to_i}"
  end
end
```

## Result Structure

```ruby
{
  unified: true,                    # Success status
  preview_mode: false,              # Was this a dry-run?
  source_project_id: 5,
  target_project_id: 3,
  started_at: <Time>,
  completed_at: <Time>,
  duration_seconds: 45.3,

  statistics: {
    models_processed: 67,
    records_migrated: 12543,
    fast_track_count: 8234,
    medium_track_count: 3456,
    slow_track_count: 234,
    special_handling_count: 619,
    deduplicated: 12,
    errors_encountered: 0
  },

  details_by_model: {
    'CollectionObject' => {
      track: :fast,
      migrated: 8234,
      errors: []
    },
    'TaxonName' => {
      track: :special,
      migrated: 523,
      source_root_id: 456,
      target_parent_id: 123
    }
  },

  errors: [],
  rollback_performed: false,

  cached_rebuild: {
    models_rebuilt: 3,
    records_updated: 619,
    errors: []
  }
}
```

## Performance

Production timings (two real runs):

| Project | Records | TaxonNames | Duration |
|---|---|---|---|
| Zoraptera → Small Polyneoptera (64→65) | 5,244 | 176 | ~3 min |
| Isoptera → Cockroach SF (4→48) | 244,721 | 6,293 | ~11 min |

The primary bottleneck is **TaxonName** (special handling — closure_tree hierarchy
rebuild scales with subtree size, not just count). Fast-track and cached models, even
with 100k+ records, complete in seconds. The slow track is limited to ObservationMatrix
and ImportDataset, which are rarely large.

Rough estimates by TaxonName count:

- **< 500 TaxonNames**: under 2 minutes
- **500 - 2,000 TaxonNames**: 2-5 minutes
- **2,000 - 7,000 TaxonNames**: 5-12 minutes
- **7,000+ TaxonNames**: 12+ minutes

## Safety Features

1. **Transaction-based**: All changes rolled back on error
2. **Preview mode**: Test without persisting changes
3. **Error recovery**: Automatic rollback on failures

## Limitations

- **ProjectMembers are never migrated** - target project keeps its members
- **Community data** (Sources, People) is not duplicated
- **Root TaxonName conflict**: Source root becomes child of target root
- **Large datasets** may require extended processing time
- **Conflict detection is point-in-time**: Each record is validated at the moment it is processed, against the partially-migrated state of the database. A record that passes validation mid-migration could theoretically become invalid once a later-processed associated model is also moved. In practice this is guarded against by MANIFEST processing order (dependencies before dependents), and analysis of current TaxonWorks validations has not identified a concrete path where this occurs. However it is a known structural limitation of the approach.
- **CachedMap ancestors**: The cached maps for TaxonName ancestors of the target project's root will be stale after unification — they are not rebuilt because CachedRebuilder only operates within the target project. Any OTU/TaxonName nodes above the target root that gain new descendants via the merge will have incorrect cached map coverage until their caches are separately rebuilt.

## Testing

Run the comprehensive test suite:

```bash
bundle exec rspec spec/models/project_unify_spec.rb
```
