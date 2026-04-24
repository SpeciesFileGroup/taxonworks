# Overview
TaxonWorks is a Biodiversity Informatics workbench.

## Broader concepts
- Open-world data model assumptions
- Meaning and semantics prioritized in the data model
- Persistence concerns (data, rendering, processes) separated (e.g. no preferences or render logic in Data tables) 

## Architecture
- TaxonWorks is Rails 8.1.x application that follows MVC conventions
- Concerns (e.g. `app/models/concerns/`) are used extensively to balance OOP and ECS approaches
- Agnostic (no Rails methods allowed) code in `lib/utilities/`

### Conventions in `ARCHITECTURE.md`
- Read conventions when operating in/on on those paths
- Models: `app/models/ARCHITECTURE.md`
- Javascript: `app/javascript/ARCHITECTURE.md`
- Style : `app/assets/stylesheets/ARCHITECTURE.md`
- Queries and filters `lib/queries/ARCHITECTURE.md`
- Exports: `lib/export/ARCHITECTURE.md`

### Application
- Both server-side and client-side rendering are used
- Vue.js 3 is used for CS, e.g. `app/javascript/vue/` for Vue.js components and single-page applications
- PostgreSQL with PostGIS is the database
- jQuery is used for legacy reasons, new code should not reference it.

### TaxonWorks Tasks
- Most UI/UX happens in a `TaxonWorks Task`
- These are encapsulated mini-apps integrating Data

### External resources
- DO NOT access these by default
- DO access these when proposing to write or add documentation to the codebase
- Human readable docs: https://docs.taxonworks.org
- Rdoc: https://rdoc.taxonworks.org
- External API: https://api.taxonworks.org
- Homepage (philosophy/approach): https://taxonworks.org

## Code
- DO us a comment when you have provide > 50% of the code for a class " 
- DO follow conventions in ARCHITECTURE.md
- When requesting clarification from a user, propose to add it to an ARCHITECTURE.md file if it appears systemic

### Syntax
- DO prefer verbose method and variable names
- DO permit abbreviated variable names in loops and simple assignments within methods
- DO NOT change quoting format unless specifically asked to
- DO allow `sv_` abbreviation in soft validation methods

### New TaxonWorks Tasks
- Initialize with generator, see `rails generate taxon_works:task --help`
- Then write a headless functional test that reaches page without a 404
- Task are nested within Rails conventions in `tasks/`, e.g. `app/controllers/tasks/`

## Tests
- Use `rspec` - `rspec path/to/test_spec.rb`
- DO tend to test first, have it fail (RED), then make it pass (GREEN) when:
  - Work is COMPLEX
  - Work is on a MODEL
  - Work is in `lib/`
  - At the start of adding a new resource/route/page
- DO reference Factories 
  - All models have a corresponding `valid_<model>` factory
- NEVER write Controller tests unless asked to

## Git
- DO NOT try to commit unless asked
- DO remind after signficant work to commit
- DO include a concise summary in the commit log when asked to commit

## Tips
- The Otu model and its related views etc. can be used as a template when determining conventions
- Use Filters (`lib/queries/*`) to gather data
- Only consider raw SQL for performance 

## Claude interactions
- Write plans,logs, summaries etc. to `./claude/log/<git_branch_name>_<date_time>
