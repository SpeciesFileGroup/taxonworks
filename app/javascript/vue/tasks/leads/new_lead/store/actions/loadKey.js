import { Lead } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import setParam from '@/helpers/setParam'

export default async function(id_or_couplet) {
  let lo = undefined
  let error_message = undefined
  if (typeof(id_or_couplet) == 'object') {
    lo = id_or_couplet
  } else if (typeof(id_or_couplet) == 'number') {
    this.loading = true
    try {
      lo = (await Lead.find(id_or_couplet)).body
    }
    catch(e) {
      error_message = `Unable to load: couldn't find id ${id_or_couplet}.`
    }
    this.loading = false
  } else {
    error_message = 'Unable to load: unrecognized id.'
  }

  if (error_message) {
    this.$reset()
    setParam(RouteNames.NewLead, 'lead_id')
    error_message = error_message + " You've been redirected to the New Key page."
    TW.workbench.alert.create(error_message, 'error')
    return;
  }

  this.root = lo.root
  this.lead = lo.lead
  this.left = lo.left
  this.right = lo.right
  this.parents = lo.parents
  this.left_future = lo.left_future
  this.right_future = lo.right_future
  this.left_had_redirect_on_save = lo.left && !!lo.left.redirect_id
  this.right_had_redirect_on_save = lo.right && !!lo.right.redirect_id

  setParam(RouteNames.NewLead, 'lead_id', lo.lead.id)
}
