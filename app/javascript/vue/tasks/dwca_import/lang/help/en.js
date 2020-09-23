//  New taxon name
//  language: en

import dwcTerms from '../../const/dwcTerms'

const createDwcTable = ({ name, qualName, description, examples }) => `
<table class="table dwc-table-help">
  <tbody>
    <tr><th colspan="2">${name}</th></tr>
    <tr class="contextMenuCells even">
      <td class="theme-label">Identifier</td>
      <td><a href="${qualName}" target="_blank">${qualName}</a></td>
    </tr>
    <tr class="contextMenuCells">
      <td class="theme-label">Definition</td>
      <td>${description}</td>
    </tr>
    <tr class="contextMenuCells even">
      <td class="theme-label">Examples</td>
      <td>${examples}</td>
    </tr>
  </tbody>
</table>`

const helpData = {
  section: {
    dwcTable: {}
  }
}

dwcTerms.forEach(term => {
  helpData.section.dwcTable[term.name] = createDwcTable(term)
})

export default helpData
