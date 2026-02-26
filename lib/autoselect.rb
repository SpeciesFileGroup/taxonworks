# lib/autoselect.rb
#
# Namespace module for the Autoselect framework.
# Model-specific autoselects live in lib/autoselect/<model_name>/ and
# inherit from Autoselect::Base.
#
# Autoselects are multi-level, escalating search selectors. Each level is a named
# strategy. When a level returns no results, the fuse mechanic (UI) automatically
# fires the next level. Operators (e.g. !r, !rm, !?) are `!`-prefixed inline
# commands that modify search behavior.
#
module Autoselect
end
