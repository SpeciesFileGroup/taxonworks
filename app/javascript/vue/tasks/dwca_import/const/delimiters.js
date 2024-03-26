import { FILE_TYPE } from './filetypes'

export const FIELD_DELIMITER = {
  Tab: '\t',
  Comma: ',',
  Semicolor: ';',
  Space: ' ',
  Other: 'other'
}

export const STRING_DELIMITER = {
  SingleQuote: "'",
  DoubleQuote: '"'
}

export const TYPES_OPTS = {
  [FILE_TYPE.TXT]: {
    field: FIELD_DELIMITER.Tab,
    str: STRING_DELIMITER.DoubleQuote
  },
  [FILE_TYPE.TSV]: {
    field: FIELD_DELIMITER.Tab,
    str: STRING_DELIMITER.DoubleQuote
  },
  [FILE_TYPE.CSV]: {
    field: FIELD_DELIMITER.Comma,
    str: STRING_DELIMITER.DoubleQuote
  }
}
