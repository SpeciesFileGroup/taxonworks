// The name actually used for matching/grouping a row: a manual override
// takes precedence over a regex-modifier result, which takes precedence
// over the row's raw scientificName.
export default (row) =>
  row.userMatchString || row.regexMatchString || row.scientificName
