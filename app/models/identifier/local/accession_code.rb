# The Local Identifier used in the specimen (collection object) accession process. It may be attached
# to a CollectionObject *or* a CollectingEvent. 

# The cannonical use is within a workflow that includes collecting, labelling, and curating a specimen,
# i.e. the process that brings specimens into a collection.
#
# AccessionCodes are not meant to act as CatalogNumbers, in that sense they are annotate a process that
# happens prior to a CollectionObject recieving a CatalogNumber
#
class Identifier::Local::AccessionCode < Identifier::Local

  # TODO: Validate scope to CollectionObject, CollectingEvent at present

end
