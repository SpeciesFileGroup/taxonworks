// Maps normalised DwC sex values to display symbols.
// Mirrors Utilities::MaterialExamined::SEX_SYMBOLS on the Ruby side.
// Matching is fuzzy: case-insensitive, plurals ('females' → 'female'),
// and gynandromorph variants ('Gynandromorphic', 'gynandomorph', …) all resolve correctly.
export const SEX_SYMBOLS = {
  male:          '♂',
  female:        '♀',
  gynandromorph: '♂♀'
}
