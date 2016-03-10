$(document).ready ->
  if $('#hub_tabs').length
   $('#' + $('#hub_tabs').data('currentTab')).addClass('current_hub_category')
