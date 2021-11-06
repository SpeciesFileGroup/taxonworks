import baseCRUD, { annotations } from './base'
import AjaxCall from 'helpers/ajaxCall'

const model = 'sources'
const permitParams = {
  bibtex_input: String,
  source: {
    serial_id: Number,
    address: String,
    annote: String,
    author: String,
    booktitle: String,
    chapter: String,
    crossref: String,
    edition: String,
    editor: String,
    howpublished: String,
    institution: String,
    journal: String,
    key: String,
    month: String,
    note: String,
    number: String,
    organization: String,
    pages: String,
    publisher: String,
    school: String,
    series: String,
    title: String,
    type: String,
    volume: String,
    doi: String,
    abstract: String,
    copyright: String,
    language: String,
    stated_year: String,
    verbatim: String,
    bibtex_type: String,
    day: String,
    year: String,
    isbn: String,
    issn: String,
    verbatim_contents: String,
    verbatim_keywords: String,
    language_id: Number,
    translator: String,
    year_suffix: String,
    url: String,
    style_id: Number,
    convert_to_bibtex: String,
    roles_attributes: {
      id: Number,
      _destroy: Boolean,
      type: String,
      person_id: Number,
      position: Number,
      person_attributes: {
        last_name: String,
        first_name: String,
        suffix: String,
        prefi: String
      }
    },
    project_sources_attributes: {
      project_id: Number
    }
  }
}

export const Source = {
  ...baseCRUD(model, permitParams),
  ...annotations(model),

  clone: (id, params) => AjaxCall('post', `/${model}/${id}/clone`, params),

  parse: params => AjaxCall('get', `/${model}/parse.json`, { params })
}
