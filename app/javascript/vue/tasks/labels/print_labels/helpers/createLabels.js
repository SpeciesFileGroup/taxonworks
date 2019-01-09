
function createLabel(label, cssStyle) {
  return `<div class="${cssStyle}">${label.text}</div>`
}

function getLinesCount(str) {
  return str.split(/\r\n|\r|\n/).length
}

function createHeader() {
  return `<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <title>TW - Labels</title>
    <meta http-equiv="content-type" content="text/html;charset=utf-8" />
    <style>
    div.ce_lbl_insect_compressed { /* this is good now, make another type if you want a new one */
      font-size: 4pt;
      font-family: Times;
      line-height: 3.2pt;
      margin: 0;
      margin-bottom: .8pt;
      white-space: pre;
    }
    
    div.ce_lbl_insect { /* sensu NCSU insect museum */ 
      font-size: 4pt;
      font-family: Times;
      margin: 0;
      margin-bottom: .8pt;
      white-space: pre;
    }
    
    div.ce_lbl_4_dram_ETOH { /* sensu Cammack */
      font-size: 8pt;
      font-family: Times;
      line-height: 8.2pt;
      margin: 0;
      margin-bottom: .8pt;
      white-space: pre;
    }
    
    div.ce_label_col {
      float: left;
      background: white;
      padding-right: 4px;
    }
    
    div.ce_label_pg {
      float: left;
      background: white;
      padding-right: 4px;
      margin: .2em;
    }
    </style>
  </head>`
}

function addSeparator(separator, spaceAround) {
  if(separator.length) {
    if(spaceAround) {
      return `<br>${separator}<br>`
    }
    else {
      return separator
    }
  }
  return ''
}

function createPages(labels, maxColumns, maxRows, divisor, cssStye, separator = '', spaceAround) {
  let columns = 1
  let pages = createHeader() + `<body><div class="ce_label_pg"><div class="ce_label_col">`
  

  labels.forEach(label => {
    let labelLines = getLinesCount(label.text)
    let rowLines = 0
    for(var i = 0; i < label.total; i++) {
      rowLines = rowLines + labelLines
      pages = pages + createLabel(label, cssStye)
      if(rowLines >= maxRows) {
        pages = pages + `</div><div class="ce_label_col">`
        columns = columns + 1
        rowLines = 0
        if(columns > maxColumns) {
          columns = 1
          pages = pages + `</div></div><div class="ce_label_pg"><div  class="ce_label_col">`
        }
      }
    }
    pages = pages + addSeparator(separator, spaceAround)
  })
  pages = pages + `</body></html>`
  return pages
}

export default createPages