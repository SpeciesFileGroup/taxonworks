class TaxonWorks::Error < StandardError; end;
class TaxonWorks::Error::API < TaxonWorks::Error; end;
class TaxonWorks::Error::NestedQuery < TaxonWorks::Error::API; end;
