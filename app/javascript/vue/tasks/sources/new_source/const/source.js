import { SOURCE_BIBTEX } from '@/constants'

export default function (source = {}) {
  const authors = source.author_roles || []
  const editors = source.editor_roles || []
  const roles = [].concat(authors, editors).filter((item) => item)

  return {
    id: undefined,
    type: SOURCE_BIBTEX,
    bibtex_type: undefined,
    title: '',
    serial_id: undefined,
    address: undefined,
    annote: undefined,
    author: undefined,
    booktitle: undefined,
    chapter: undefined,
    crossref: undefined,
    edition: undefined,
    editor: undefined,
    howpublished: undefined,
    institution: undefined,
    journal: undefined,
    key: undefined,
    month: undefined,
    note: undefined,
    number: undefined,
    organization: undefined,
    pages: undefined,
    publisher: undefined,
    school: undefined,
    series: undefined,
    volume: undefined,
    doi: undefined,
    abstract: undefined,
    copyright: undefined,
    language: undefined,
    stated_year: undefined,
    verbatim: undefined,
    day: undefined,
    year: undefined,
    isbn: undefined,
    issn: undefined,
    verbatim_contents: undefined,
    verbatim_keywords: undefined,
    language_id: undefined,
    translator: undefined,
    year_suffix: undefined,
    url: undefined,
    ...source,
    roles_attributes: roles,
    isUnsaved: false
  }
}
