import { toRefs, reactive } from 'vue'
import { Container } from '@/routes/endpoints'
import { makeContainer } from '../adapters'

export function useContainer() {
  const state = reactive({
    isLoading: false,
    container: makeContainer()
  })

  const loadContainer = async (id) => {
    state.isLoading = true

    return Container.find(id)
      .then(({ body }) => {
        state.container = makeContainer(body)
      })
      .finally(() => {
        state.isLoading = false
      })
  }

  const newContainer = () => {
    state.container = makeContainer()
  }

  const save = () => {}

  return {
    loadContainer,
    newContainer,
    save,
    ...toRefs(state)
  }
}
