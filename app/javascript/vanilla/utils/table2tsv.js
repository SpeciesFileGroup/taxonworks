export function html2tsv(element) {
  const el =
    typeof element === 'string' ? document.querySelector(element) : element

  if (!el) {
    throw new Error("Element doesn't exist")
  }

  console.log(el)

  const thElements = [...el.querySelectorAll('th')]
  const trElements = [...el.querySelectorAll('tr')]

  const columnHeaders = thElements.map((el) => el.textContent).join('\t')
  const rowData = trElements.map((row) => getRowData(row).join('\t')).join('\n')

  return [columnHeaders, rowData].join('')
}

function getRowData(element) {
  const tdElements = [...element.querySelectorAll('td')]

  return tdElements.map((el) => el.textContent)
}
