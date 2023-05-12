import {
  DESCRIPTOR_CONTINUOUS,
  DESCRIPTOR_GENE,
  DESCRIPTOR_MEDIA,
  DESCRIPTOR_PRESENCE_ABSENCE,
  DESCRIPTOR_QUALITATIVE,
  DESCRIPTOR_SAMPLE,
  DESCRIPTOR_WORKING
} from 'constants/index.js'

export default Object.freeze({
  [DESCRIPTOR_QUALITATIVE]: 'Qualitative (e.g. a phylogenetic character, or telegraphic description)',
  [DESCRIPTOR_PRESENCE_ABSENCE]: 'Presence absence',
  [DESCRIPTOR_CONTINUOUS]: 'Quantitative (i.e continuous, e.g. a measurement)',
  [DESCRIPTOR_SAMPLE]: 'Sample ( a statistical summary, n, min, max, std, etc.)',
  [DESCRIPTOR_GENE]: 'Gene',
  [DESCRIPTOR_WORKING]: 'Free text',
  [DESCRIPTOR_MEDIA]: 'Media'
})
