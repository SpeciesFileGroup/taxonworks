# Dashboard Tasks

Dashboard tasks are configuration and monitoring interfaces for project-level settings (e.g., export preferences, data quality summaries). They differ from data-entry tasks in that they present an overview with multiple panels rather than a single focused workflow.

For general frontend conventions, see `app/javascript/ARCHITECTURE.md`. For style conventions, see `app/assets/stylesheets/ARCHITECTURE.md`.

## Layout

- Use a **two-column layout** for the main content area
- Each column contains stacked panels (`panel` class)
- Full-width elements (profile selector, citation, download controls) go above the two-column layout
- Minimal scoped CSS is acceptable for the column layout — utility classes alone do not cover equal-width flex columns with a gap

## Existing dashboards for reference

- ColDP export preferences: `app/javascript/vue/tasks/projects/coldp_export_preferences/`
- DwC export preferences: `app/javascript/vue/tasks/projects/dwc_export_preferences/`
