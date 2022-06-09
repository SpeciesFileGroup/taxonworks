import { convertToTwoDigits } from 'helpers/numbers'

const parseDate = extract => {
  return [
     extract.year_made,
     extract.month_made,
     extract.day_made
   ]
   .filter(Boolean)
   .map(d => convertToTwoDigits(d))
   .join('/')
 }

export default (extracts) =>
  extracts.map(e => ({
    id: e.id,
    global_id: e.global_id,
    otus: e.otus.join(', '),
    identifiers: e.identifiers.join(', '),
    originsType: e.origin_types.join(', '),
    origins: e.origins.join(', '),
    verbatim_anatomical_origin: e.verbatim_anatomical_origin,
    date: parseDate(e)
  }))
