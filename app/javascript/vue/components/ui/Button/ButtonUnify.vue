<template>
  <VBtn
    icon
    color="primary"
    variant="tonal"
    :disabled="disabled"
    @click="() => openUnify(false)"
    @contextmenu="() => openUnify(true)"
    title="Unify objects"
  >
    <IconCombine class="w-4 h-4" />
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import IconCombine from '@/components/Icon/IconCombine.vue'
import { RouteNames } from '@/routes/routes'
import { computed } from 'vue'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  model: {
    type: String,
    required: true
  }
})

const disabled = computed(
  () => props.ids.length !== 2 || !ID_PARAM_FOR[props.model]
)

function openUnify(newTab) {
  const params = props.ids
    .map((id) => `${ID_PARAM_FOR[props.model]}[]=${id}`)
    .join('&')

  window.open(
    `${RouteNames.UnifyObjects}?${params}`,
    newTab ? '_blank' : 'self'
  )
}
</script>
