<template>
  <VModal
    v-if="isModalVisible"
    @close="isModalVisible = false"
    :container-style="{ width: '600px' }"
  >
    <template #header>
      <h3>Nested parameters</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <li
          v-for="(params, objType) in queryParameters"
          :key="objType"
        >
          <div class="flex-separate middle">
            <span>{{ objType }}</span>
            <VBtn
              class="middle"
              color="primary"
              medium
              @click="openFilterFor(objType, params)"
            >
              Go
            </VBtn>
          </div>
          <pre
            class="break_words_pre"
            v-text="JSON.stringify(params, null, 2)"
          />
        </li>
      </ul>
    </template>
  </VModal>
  <VBtn
    class="middle"
    color="primary"
    medium
    :disabled="isEmpty"
    @click="isModalVisible = true"
  >
    <VIcon
      x-small
      :color="isEmpty ? 'currentColor' : 'warning'"
      name="attention"
    />
    <span class="margin-xsmall-left">Nested</span>
  </VBtn>
</template>

<script setup>
import { ref, computed } from 'vue'
import { QUERY_PARAM } from 'components/radials/filter/constants/queryParam'
import { FILTER_ROUTES } from 'routes/routes'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import qs from 'qs'

const props = defineProps({
  parameters: {
    type: Object,
    default: () => ({})
  }
})

const isEmpty = computed(() => !Object.keys(queryParameters.value).length)

const queryParameters = computed(() => {
  const params = Object.keys(props.parameters).filter((key) =>
    key.includes('_query')
  )

  return Object.fromEntries(
    params.map((param) => {
      const [objectType] = Object.entries(QUERY_PARAM).find(
        ([_, key]) => param === key
      )

      return [objectType, props.parameters[param]]
    })
  )
})

function openFilterFor(objType, params) {
  const url = `${FILTER_ROUTES[objType]}?${qs.stringify(params)}`

  window.open(url, '_self')
}

const isModalVisible = ref(false)
</script>
