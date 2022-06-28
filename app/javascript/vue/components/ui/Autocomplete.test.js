import { render, screen, fireEvent } from '@testing-library/vue'
import VAutocomplete from './Autocomplete.vue'

describe('Autocomplete component', () => {
  const setup = () => {
    const utils = render(VAutocomplete, {
      props: {
        url: '/taxon_names/autocomplete',
        param: 'term',
        label: 'label_html',
        delay: 0
      }
    })
    const input = utils.container.querySelector('input')

    return {
      utils,
      input
    }
  }

  it('search and display results', async () => {
    const { input } = setup()

    fireEvent.update(input, 'foo')
    await screen.findByText('Foo bar')
  })
})
