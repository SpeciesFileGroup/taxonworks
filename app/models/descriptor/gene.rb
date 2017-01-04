# A Descriptor::Gene defines a set of sequeces, i.e. column in a "matrix" whose
# cells contains sequences that match the a set (logical AND) of GeneAttributes. 
#
# The column (conceptually set of sequences) is populated by things that match (all) of the GeneAttibutes attached to the Descriptor::Gene.
# 
class Descriptor::Gene < Descriptor

    has_many :gene_attributes, inverse_of: :descriptor

end
