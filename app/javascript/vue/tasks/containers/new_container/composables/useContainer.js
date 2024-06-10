import { toRefs, reactive } from 'vue'
import { Container } from '@/routes/endpoints'
import { makeContainer, makeContainerPayload } from '../adapters'

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

  const save = (data) => {
    Container.create({
      container: makeContainerPayload(data)
    })
      .then(({ body }) => {
        state.container = makeContainer(body)
      })
      .catch(() => {})
  }

  return {
    loadContainer,
    newContainer,
    save,
    ...toRefs(state)
  }
}
