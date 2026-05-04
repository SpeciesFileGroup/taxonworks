# Dashboard Tasks

Dashboard tasks are configuration and monitoring interfaces for project-level settings (e.g., export preferences, data quality summaries). They differ from data-entry tasks in that they present an overview with multiple panels rather than a single focused workflow.

## Layout

- Use a **two-column layout** for the main content area
- Each column contains stacked panels (`panel` class)
- Use minimal scoped CSS for the column layout — utility classes alone do not cover equal-width flex columns with a gap

```vue
<div class="two-column">
  <div class="flex-col gap-medium">
    <!-- Left column panels -->
  </div>
  <div class="flex-col gap-medium">
    <!-- Right column panels -->
  </div>
</div>

<style scoped>
.two-column {
  display: flex;
  gap: 2em;
  margin-top: 1em;
}

.two-column > div {
  flex: 1;
}
</style>
```

- Full-width elements (profile selector, citation, download controls) go above the two-column layout
- Panels use the global `panel padding-large` classes

## Styling

- **Use TaxonWorks utility classes** — do not write custom CSS for spacing, alignment, text, or feedback
- **Scoped styles are acceptable only for**:
  - Column layout (as above)
  - Third-party library theming (CodeMirror, Leaflet)
- Refer to `app/assets/stylesheets/ARCHITECTURE.md` for the semantic palette

### Common utility classes for dashboards

| Purpose | Classes |
|---------|---------|
| Panel container | `panel padding-large` |
| Horizontal row with centered items | `horizontal-left-content gap-small` |
| Space-between header row | `flex-separate middle` |
| Two buttons side by side | `horizontal-left-content gap-small` or `gap-medium` |
| Status indicators | `feedback-success`, `feedback-warning`, `feedback-danger` with `padding-xsmall` |
| Small helper text | `small_type` |
| Full-width input | `full_width` |
| Table | `vue-table` (already sets `width: 100%`) |

### Toast notifications over inline feedback

Use `TW.workbench.alert.create(message, type)` for transient messages (validation results, save confirmations, errors). Inline feedback divs become stale when the user edits content after validation.

- `'notice'` — success (green)
- `'error'` — failure (red)

Reserve inline `feedback-warning` / `feedback-danger` divs only for persistent warnings that should always be visible (e.g., "No dataset ID configured").

## Components

- Reuse global components from `app/javascript/vue/components/ui/`
- Use `VBtn` with semantic colors: `color="create"` (save/POST), `color="destroy"` (delete), `color="primary"` (actions)
- Use `Autocomplete` for entity lookups, not custom search inputs
- Use `VSpinner` for loading states
- Use `ButtonClipboard` for copy-to-clipboard

## Backend conventions

- Controller actions should be thin dispatchers — business logic belongs in models or `lib/`
- External API calls belong in `lib/vendor/` wrapper modules, not controllers
- Use `params.permit(...)` consistently for all parameter access
- Standardize error responses: `{ error: 'message' }` for single errors
- Use specific `rescue` clauses (not bare `rescue`) — catch expected exceptions, let bugs propagate

## Existing dashboards for reference

- ColDP export preferences: `app/javascript/vue/tasks/projects/coldp_export_preferences/`
- DwC export preferences: `app/javascript/vue/tasks/projects/dwc_export_preferences/`
