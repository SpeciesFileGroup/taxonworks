
import { getPastDateByDays } from './dates.js'

describe('Date helpers', () => {
  it('get date from days 2 days ago', () => {
    const result = getPastDateByDays(2, new Date('2022/02/20'))

    expect(result).toBe('2022-02-18')
  })
})
