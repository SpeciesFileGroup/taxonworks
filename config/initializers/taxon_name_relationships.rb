# Be sure to restart your server (or console) when you modify this file.

# All TaxonNameRelationship Classes
# TODO: scope to assignable
TAXON_NAME_RELATIONSHIPS = TaxonNameRelationship.descendants 

# Array of all ICZN TaxonNameRelationship classes, as Strings 
ICZN_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship::Iczn.descendants.collect{|d| d.to_s} 

# Array of all ICN TaxonNameRelationship classes, as Strings 
ICN_TAXON_NAME_RELATIONSHIP_NAMES = TaxonNameRelationship::Icn.descendants.collect{|d| d.to_s} 

# Array of all TaxonNameRelationship classes, as Strings 
TAXON_NAME_RELATIONSHIP_NAMES = TAXON_NAME_RELATIONSHIPS.collect{|r| r.to_s} 

