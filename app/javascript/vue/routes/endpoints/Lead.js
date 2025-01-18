import baseCRUD from './base'
import AjaxCall from '@/helpers/ajaxCall.js'

const controller = 'leads'
const permitParams = {
  lead: {
    id: Number,
    parent_id: Number,
    otu_id: Number,
    text: Text,
    origin_label: String,
    description: Text,
    redirect_id: Number,
    link_out: Text,
    link_out_text: String,
    is_public: Boolean,
    global_id: String
  }
}

export const Lead = {
  ...baseCRUD(controller, permitParams),

  insert_couplet: (id) => AjaxCall(
    'post', `/${controller}/${id}/insert_couplet.json`
  ),

  edit: (id) => AjaxCall(
    'get', `/${controller}/${id}/edit.json`
  ),

  create_for_edit: (id) => AjaxCall(
    'post', `/${controller}/${id}/create_for_edit.json`
  ),

  redirect_option_texts: (id) => AjaxCall(
    'get', `/${controller}/${id}/redirect_option_texts.json`
  ),

  destroy_children: (id) => AjaxCall(
    'post', `/${controller}/${id}/destroy_children.json`
  ),

  delete_children: (id) => AjaxCall(
    'post', `/${controller}/${id}/delete_children.json`
  ),

  otus: (id) => AjaxCall(
    'get', `/${controller}/${id}/otus.json`
  ),

  add_lead: (id) => AjaxCall(
    'post', `/${controller}/${id}/add_lead.json`
  ),

  destroy_subtree: (id) => AjaxCall(
    'post', `/${controller}/${id}/destroy_subtree.json`
  ),

  swap: (id, params) => AjaxCall(
    'patch', `/${controller}/${id}/swap.json`, params
  ),

  insert_key: (id, params) => AjaxCall(
    'post', `/${controller}/${id}/insert_key.json`, params
  )
}