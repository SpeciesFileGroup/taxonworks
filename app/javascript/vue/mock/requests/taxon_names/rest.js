import { rest } from 'msw'
import { autocompleteResponse } from './responses/autocomplete.js'

export const taxonNameRestHandlers = [
  rest.get('*/taxon_names/autocomplete', (req, res, ctx) => {
    const termValue = req.url.searchParams.get('term')

    return res(ctx.status(200), ctx.json(
      termValue === 'foo'
        ? autocompleteResponse
        : []
    ))
  })
]
