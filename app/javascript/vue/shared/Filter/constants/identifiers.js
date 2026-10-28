export const IDENTIFIER_PROPERTIES = ['cached']

// Joins a row's identifiers for display. The backend sorts the identifiers
// column on the same string (Queries::Sort::Resolver::JOINED_SEPARATOR), and identifiers
// arrive already in position order.
export const IDENTIFIER_SEPARATOR = ' | '
