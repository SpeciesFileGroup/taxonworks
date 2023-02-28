export const ROLE_ACCESSION_RPOVIDER = 'AccessionProvider'
export const ROLE_ATTRIBUTION_COPYRIGHT_HOLDER = 'AttributionCopyrightHolder'
export const ROLE_ATTRIBUTION_CREATOR = 'AttributionCreator'
export const ROLE_ATTRIBUTION_EDITOR = 'AttributionEditor'
export const ROLE_ATTRIBUTION_OWNER = 'AttributionOwner'
export const ROLE_COLLECTOR = 'Collector'
export const ROLE_DEACCESSION_RECIPIENT = 'DeaccessionRecipient'
export const ROLE_DETERMINER = 'Determiner'
export const ROLE_EXTRACTOR = 'Extractor'
export const ROLE_GEOREFERENCER = 'Georeferencer'
export const ROLE_LOAN_RECIPIENT = 'LoanRecipient'
export const ROLE_LOAN_SUPERVISOR = 'LoanSupervisor'
export const ROLE_SOURCE_AUTHOR = 'SourceAuthor'
export const ROLE_SOURCE_EDITOR = 'SourceEditor'
export const ROLE_SOURCE_ROLE = 'Role::SourceRole'
export const ROLE_SOURCE_SOURCE = 'SourceSource'
export const ROLE_TAXON_NAME_AUTHOR = 'TaxonNameAuthor'
export const ROLE_VERIFIER = 'Verifier'

export const TAXON_NAME_AUTHOR_SELECTOR = [ROLE_TAXON_NAME_AUTHOR] // TN / 'Authors(s)

export const DETERMINER_SELECTOR = [ROLE_DETERMINER] // CO, CE / Detrminer

export const COLLECTOR_SELECTOR = [ROLE_COLLECTOR] // CO, CE / Collector

export const SOURCE_AUTHOR_SELECTOR = [ROLE_SOURCE_AUTHOR] // Source / Author

export const SOURCE_EDITOR_SELECTOR = [ROLE_SOURCE_EDITOR] // !! furture use, don't implement Source / Editor

// Doesn't follow same pattern as above
export const LOAN_ROLE_SELECTOR = [ROLE_LOAN_RECIPIENT, ROLE_LOAN_SUPERVISOR] // Loan / Person (R/S) hmmm- has toggles already

