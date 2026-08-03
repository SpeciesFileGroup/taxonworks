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

# Surface elevation

Background surfaces are organized in three layers. Pick the layer by *how the
element sits in space*, not by how it looks — a menu is layer 3 even when it
happens to be the same color as a card in light mode.

1. **Page** — `--bg-color`. The canvas everything else sits on.
2. **Content** — `--panel-bg-color` / `--bg-foreground`. Cards, panels, in-flow
   regions (`.tw-card`, task panels). `--bg-muted` / `--bg-hover` are the
   recessed and hover fills *within* this layer.
3. **Overlay** — `--bg-overlay`. Anything that floats over the content and is
   dismissible: context menus, popovers (`.tw-popover`, `.tw-menu`),
   autocomplete/autoselect dropdowns, navigation dropdowns.

In dark mode layer 3 is *lighter* than layer 2, so a menu opened over a card
still reads as being above it. In light mode both are white and the separation
comes from the border and shadow the component already carries.

Modals are excluded: they are separated by the dimmed backdrop
(`--modal-mask-bg-color`) and keep `--panel-bg-color`. Tooltips are their own
component token set (`--tooltip-bg-color`).

# Semantic palette

- Green is only used to indicate buttons or actions that will POST or PATCH to the database
- Red is only used to indicate buttons or actions that will DELETE from the database
- Primary/blue (`--color-primary`): neutral/navigational actions and selected state — the default interactive accent that is neither create (green) nor destroy (red)
- Warning/yellow (`--color-warning`, amber/orange): reversible-but-risky actions and non-blocking cautions (e.g. soft validation, "are you sure")
- Muted/gray (`--text-muted-color`, `--button-disabled-*`): disabled, inactive, or secondary/de-emphasized content
- Borders come in two weights: `--border-color` delimits a thing from what surrounds it (input, card, menu edge); `--border-weak-color` separates content *within* an already-delimited surface (dividers, row rules, list separators). If a border is competing with the content it contains, it should be the weak one
- Focus: every interactive element gets a visible focus ring via `--focus-ring` (WCAG 2.2 §2.4.13); do not remove `outline` without providing an equivalent
