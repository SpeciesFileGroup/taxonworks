//  language: en

import dwcTerms from '../../const/dwcTerms'

function makeList(arr) {
  return `
  <ul>
    ${arr.map((item) => `<li>${item}</li>`).join('')}
  </ul>
  `
}

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
    dwcTable: {},
    import: {
      dropzone: `
      <span>Supported formats:</span>
      <ul>
        <li>Darwin Core Archive (DwC-A) ZIP file with meta.xml and data files inside (preferred)</li>
        <li>Tab-separated values text file (TXT, TSV)</li>
        <li>Spreadsheet (XLS, XLSX and ODS supported)</li>
      </ul>
      <p>
        Required columns for occurrence data:
          ${makeList(TW.constants.DWC_OCCURRENCES_MINIMUN_FIELD_SET)}
      </p>
      <p>
        Required columns for checklist data:
          ${makeList(TW.constants.DWC_CHECKLIST_MINIMUN_FIELD_SET)}
      </p>
      `
    }
  }
}

dwcTerms.forEach((term) => {
  helpData.section.dwcTable[term.name] = createDwcTable(term)
})

export default helpData
