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
  },
  left: {
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
  },
  right: {
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

  update_meta: (id, params) => AjaxCall(
    'patch', `/${controller}/${id}/update_meta.json`, params
  ),

  insert_couplet: (id) => AjaxCall(
    'post', `/${controller}/${id}/insert_couplet.json`
  ),

  edit: (id) => AjaxCall(
    'get', `/${controller}/${id}/edit.json`
  ),

  create_for_edit: (id) => AjaxCall(
    'post', `/${controller}/${id}/create_for_edit.json`
  ),

  all_texts: (id) => AjaxCall(
    'get', `/${controller}/${id}/all_texts.json`
  ),

  destroy_couplet: (id) => AjaxCall(
    'post', `/${controller}/${id}/destroy_couplet.json`
  ),

  delete_couplet: (id) => AjaxCall(
    'post', `/${controller}/${id}/delete_couplet.json`
  )
}