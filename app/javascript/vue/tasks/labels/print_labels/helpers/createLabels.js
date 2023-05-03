
import cssStyle from '!!css-loader!sass-loader!../stylesheets/ce.scss'
import {
  LABEL_CODE_128,
  LABEL_QR_CODE
} from 'constants/index.js'

const labelTypes = {
  [LABEL_CODE_128]: 2.75,
  [LABEL_QR_CODE]: 3.05
}

const createLabel = (label, cssStyle) => `<div class="${cssStyle}">${label.label}</div>`

const getLinesCount = (str, labelType) => labelTypes[labelType] ? labelTypes[labelType] : str.split(/\r\n|\r|\n/).length

const createHeader = (customClass) =>
`<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <title>TW - Labels</title>
    <style>
    ${cssStyle}

    div.custom_style { ${customClass} }
    </style>
  </head>`

function addSeparator (separator, spaceAround) {
  if (separator.length) {
    if (spaceAround) {
      return `<br>${separator}<br>`
    } else {
      return separator
    }
  }
  return ''
}

function createPages (labels, maxColumns, maxRows, divisor, cssStye, customStyle, separator = '', spaceAround) { // add labelType ?
  let columns = 1
  let pages = `${createHeader(customStyle)}<body><div class="ce_label_pg"><div class="ce_label_col">`
  let rowLines = 0

  labels.forEach(label => {
    const labelLines = getLinesCount(label.text, label.type)

    for (let i = 0; i < label.total; i++) {
      rowLines = rowLines + labelLines
      pages = pages + (label.is_generated ? label.label : createLabel(label, cssStye))

      if (rowLines >= maxRows) {
        pages = pages + '</div><div class="ce_label_col">'
        columns = columns + 1
        rowLines = 0
        if (columns > maxColumns) {
          columns = 1
          pages = pages + '</div></div><div class="ce_label_pg"><div  class="ce_label_col">'
        }
      }
    }
    pages = pages + addSeparator(separator, spaceAround)
  })
  pages = pages + '</body></html>'
  return pages
}

export default createPages
