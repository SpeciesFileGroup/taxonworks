# Organization

In `app/assets/stylesheets/`

* base/ - core element styles, covering the general defaults (i.e. color palette, white space, etc)
* views/ - css for classes that originate in `app/views/`
* helpers/ - css for classes that originate in `app/helpers/`
* vendor/ - css that references libraries that aren't TW origin
* tasks/ - css for TaxonWorks tasks (TODO: most task styles are in Vue components, clarify when to use this vs component scoped styles)

See also `app/assets/javascript/vue/assets/styles/`.

# CSS

* DO ALWAYS use shared styles libraries for buttons, links, and fonts for both SS and vue.js work

# Color token architecture

Colors are organized in three layers. Always consume the *highest* layer that
fits; never reach down a layer (a component must not read a primitive directly).

1. **Primitive tokens** — `app/javascript/vue/assets/styles/variables/_primitives.scss`.
   Raw, role-less values on a 50–950 ramp (`--blue-500`, `--gray-700`, …). Single
   source of truth for the palette. Do not consume these in components.
2. **Semantic tokens** — `variables/_palette.scss` `:root`. Role-based names that
   reference primitives (`--text-color`, `--border-color`, `--color-danger`,
   `--surface`…). This is the only layer Dark Mode (`.dark`) overrides.
3. **Component tokens** — same file / component partials. Reference semantic
   tokens (`--tooltip-bg-color`, `--badge-blue-bg`, `--btn-radial-color`).

Notes:
- The `tw-`/`--color-*` prefixes mean **TaxonWorks**, not Tailwind. Tailwind is
  not used in this project.
- Button foreground color is derived automatically for contrast via the
  `on-color()` SCSS function (`utils/functions.scss`); never hardcode
  `color: white` on a colored button — use `var(--color-on-<key>)`.
- `app/assets/stylesheets/base/_palette.scss` is the **legacy** Paletton-based
  SCSS-variable system, kept only for server-rendered views still referencing it.
  Do not add to it; migrate consumers to the CSS-custom-property layers above.

# Semantic palette

- Green is only used to indicate buttons or actions that will POST or PATCH to the database
- Red is only used to indicate buttons or actions that will DELETE from the database
- Primary/blue (`--color-primary`): neutral/navigational actions and selected state — the default interactive accent that is neither create (green) nor destroy (red)
- Warning/yellow (`--color-warning`, amber/orange): reversible-but-risky actions and non-blocking cautions (e.g. soft validation, "are you sure")
- Muted/gray (`--text-muted-color`, `--button-disabled-*`): disabled, inactive, or secondary/de-emphasized content
- Focus: every interactive element gets a visible focus ring via `--focus-ring` (WCAG 2.2 §2.4.13); do not remove `outline` without providing an equivalent
