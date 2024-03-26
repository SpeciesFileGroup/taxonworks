import { FILE_TYPE } from './filetypes'

export const FIELD_DELIMITER = {
  Tab: '\t',
  Comma: ',',
  Semicolor: ';',
  Space: ' ',
  Other: 'other'
}

export const STRING_DELIMITER = ["'", '"']

export const TYPES_OPTS = {
  [FILE_TYPE.TXT]: {
    field: FIELD_DELIMITER.Tab,
    str: '"'
  },
  [FILE_TYPE.TSV]: {
    field: FIELD_DELIMITER.Tab,
    str: '"'
  },
  [FILE_TYPE.CSV]: {
    field: FIELD_DELIMITER.Comma,
    str: '"'
  }
}
