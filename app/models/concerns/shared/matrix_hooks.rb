# Observation matrix hooks that facilitate the dynamic updating of matrices.
#
# !! Do not include this library, but rather the corresponding reference libraries:
#
# The pattern is this:
# * All objects in that scope trigger code that is cleaned up via code in their respective _item classes
# 
module Shared::MatrixHooks

  extend ActiveSupport::Concern
  included do
  end

  module ClassMethods
  end

end
