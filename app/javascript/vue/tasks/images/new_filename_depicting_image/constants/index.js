export const ROLE = {
  Identifier: 'identifier',
  Label: 'label',
  Caption: 'caption',
  Ignore: 'ignore'
}

export const ROLE_LABELS = {
  [ROLE.Identifier]: 'Identifier',
  [ROLE.Label]: 'Label',
  [ROLE.Caption]: 'Caption',
  [ROLE.Ignore]: 'Ignore'
}

export const UNIQUE_ROLES = [ROLE.Identifier, ROLE.Label, ROLE.Caption]

export const SEPARATORS = ['_', '-', ' ', '.']

export const IDENTIFIER_DELIMITERS = ['.', ':', '_']

export const STATUS = {
  Matching: 'matching',
  Matched: 'matched',
  NotFound: 'not_found',
  Ambiguous: 'ambiguous',
  PatternMismatch: 'pattern_mismatch',
  Queued: 'queued',
  Uploading: 'uploading',
  Created: 'created',
  AlreadyDepicted: 'already_depicted',
  Error: 'error'
}

export const STATUS_META = {
  [STATUS.Matching]: { label: 'Matching', color: 'default' },
  [STATUS.Matched]: { label: 'Ready', color: 'blue' },
  [STATUS.NotFound]: { label: 'Not found', color: 'yellow' },
  [STATUS.Ambiguous]: { label: 'Ambiguous', color: 'yellow' },
  [STATUS.PatternMismatch]: { label: 'Pattern mismatch', color: 'yellow' },
  [STATUS.Queued]: { label: 'Queued', color: 'default' },
  [STATUS.Uploading]: { label: 'Uploading', color: 'blue' },
  [STATUS.Created]: { label: 'Created', color: 'green' },
  [STATUS.AlreadyDepicted]: { label: 'Already depicted', color: 'default' },
  [STATUS.Error]: { label: 'Error', color: 'red' }
}

export const STATUS_DESCRIPTIONS = {
  [STATUS.NotFound]: 'No collection object has this identifier',
  [STATUS.Ambiguous]: 'More than one collection object has this identifier',
  [STATUS.PatternMismatch]: 'The filename does not match the filename pattern'
}

export const ROLE_COLORS = {
  [ROLE.Identifier]: 'blue',
  [ROLE.Label]: 'purple',
  [ROLE.Caption]: 'green',
  [ROLE.Ignore]: 'yellow'
}
