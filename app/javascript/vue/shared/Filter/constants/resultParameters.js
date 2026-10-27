// Filter params that page, order or shape a result, rather than say which
// records are in it. Radials that act on, or send on, a filter's whole set
// drop them: a batch action covers the whole set, and another task applies
// its own paging and order (a forwarded sort key may not even exist there).
export const RESULT_PARAMETERS = [
  'per',
  'page',
  'extend',
  'exclude',
  'sort',
  'recent',
  'recent_target',
  'order_by'
]
