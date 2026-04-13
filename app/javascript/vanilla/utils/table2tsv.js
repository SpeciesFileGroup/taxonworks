export function html2tsv(element, options = {}) {
  const el =
    typeof element === 'string' ? document.querySelector(element) : element

  if (!el) {
    throw new Error("Element doesn't exist")
  }

  const { offset } = options
  const thElements = [...el.querySelectorAll('th')]
  const trElements = [...el.querySelectorAll('tr')]

  const end = options.end ? Number(options.end) : thElements.length - 1

  const columnHeaders = thElements
    .slice(offset, end + 1)
    .map((el) => el.textContent)
    .join('\t')
  const rowData = trElements
    .map((row) =>
      getRowData(row)
        .slice(offset, end + 1)
        .join('\t')
    )
    .join('\n')

  return [columnHeaders, rowData].join('')
}

function getRowData(element) {
  const tdElements = [...element.querySelectorAll('td')]

  return tdElements.map((el) => el.textContent)
}
