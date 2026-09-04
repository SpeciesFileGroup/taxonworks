These TTF files are a manual, point-in-time copy from the `pdfjs-dist` npm
package (`node_modules/pdfjs-dist/standard_fonts/`), used here to give Prawn
a Unicode-capable font for PDF generation in `SourcesController#download_formatted`.

They are not managed by Bundler or npm/yarn - upgrading `pdfjs-dist` will not
update this copy. Liberation Sans is stable/metric-compatible with Arial by
design, so drift is unlikely, but if these ever need refreshing, re-copy from
`node_modules/pdfjs-dist/standard_fonts/` (Regular, Bold, Italic, BoldItalic)
and the accompanying `LICENSE_LIBERATION` file.
