//  language: en

import dwcTerms from '../../const/dwcTerms'

function makeList(arr) {
  return `
  <ul>
    ${arr.map((item) => `<li>${Array.isArray(item) ? item.join(', ') : item}</li>`).join('')}
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
        For occurrence data, the dataset must include every field in at least one of the following sets:
          ${makeList(TW.constants.DWC_OCCURRENCES_MINIMUM_FIELD_SET)}
      </p>
      <p>
        For checklist data, the dataset must contain all fields from at least one of the following sets:
          ${makeList(TW.constants.DWC_CHECKLIST_MINIMUM_FIELD_SET)}
      </p>
      `
    }
  }
}

dwcTerms.forEach((term) => {
  helpData.section.dwcTable[term.name] = createDwcTable(term)
})

export default helpData
