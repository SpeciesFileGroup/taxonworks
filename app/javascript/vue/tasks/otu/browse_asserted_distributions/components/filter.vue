<template>
  <BlockLayout>
    <template #header>
      <h3>OTU</h3>
    </template>

    <template #options>
      <VBtn
        color="primary"
        circle
        @click="resetFilter"
      >
        <VIcon
          name="reset"
          x-small
          title="Reset"
        />
      </VBtn>
    </template>

    <template #body>
      <OtuComponent v-model="otuId" />
      <OtuLinks :otu-id="otuId" />
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import OtuComponent from './filters/otu'
import OtuLinks from './navBar'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const otuId = ref(null)

const emit = defineEmits(['select'])

watch(otuId, (newVal) => {
  if (newVal) {
    emit('select', { otu_id: newVal })
  }

  setParam(RouteNames.BrowseAssertedDistribution, 'otu_id', newVal)
})

function resetFilter() {
  emit('reset')
  otuId.value = null
}

onMounted(() => {
  getParams()
})

function getParams() {
  const urlParams = new URLSearchParams(window.location.search)
  //const id = urlParams.get('otu_id')

  for (const p of urlParams.keys()) {
    const model = MODEL_FOR_ID_PARAM[p]
    const endpoint = ENDPOINTS_HASH[model]
    if (model && endpoint) {
      const id = urlParams.get(p)
      if (id && (/^\d+$/.test(id))) {
        loadObject(model, endpoint, id)
        break
      }
    }
  }
}

function loadObject(model, endpoint, id) {
  endpoint.find(id)
    .then(({ body }) => {
      body.objectType = model
      params.value.asserted_distribution_object = body
    })
    .catch(() => {})
}

</script>
<style scoped>
:deep(.btn-delete) {
  background-color: var(--color-primary);
}
</style>
