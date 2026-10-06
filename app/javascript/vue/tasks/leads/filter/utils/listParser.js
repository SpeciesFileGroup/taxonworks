export function listParser(list) {
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    text: item.text,
    key_type: item.is_virtual ? 'Simple' : 'Dichotomous',
    otu: item.otu?.object_tag,
    otus_count: item.otus_count,
    couplets_count: item.is_virtual ? null : item.couplets_count,
    is_public: item.is_public ? 'Yes' : 'No',
    key_updated_at: item.key_updated_at_in_words,
    key_updated_by: item.key_updated_by
  }))
}
