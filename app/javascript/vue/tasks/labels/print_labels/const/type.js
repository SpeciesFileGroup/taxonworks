import {
  LABEL,
  LABEL_QR_CODE,
  LABEL_CODE_128
} from 'constants/labelTypes'

const types = [{
  label: 'Text',
  value: LABEL
},
{
  label: 'QR Code',
  value: LABEL_QR_CODE
},
{
  label: 'Barcode',
  value: LABEL_CODE_128
}]

export default types
