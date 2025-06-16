<template>
  <BlockLayout>
    <template #header>
      <h3>Object</h3>
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
      <AssertedDistributionObjectPicker
        minimal
        autofocus
        @select-object="(o) => {
          objectId = o.id
          objectType = o.objectType
        }"
      />
      <ObjectLinks
        :objectId="objectId"
        :objectType="objectType"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { setParam } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { toSnakeCase } from '@/helpers'
import { MODEL_FOR_ID_PARAM } from '@/components/radials/filter/constants/idParams'
import { ENDPOINTS_HASH } from '../const/endpoints'
import AssertedDistributionObjectPicker from '@/components/ui/SmartSelector/AssertedDistributionObjectPicker.vue'
import ObjectLinks from './objectLinks.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const objectId = ref(null)
const objectType = ref(null)

const emit = defineEmits(['select'])

watch([objectId, objectType], ([newId, newType]) => {
  if (newId && newType) {
    emit('select', { object_id: newId, object_type: newType })
  }

  const id_param = `${toSnakeCase(newType)}_id`
  setParam(RouteNames.BrowseAssertedDistribution, id_param, newId)
})

function resetFilter() {
  emit('reset')
  objectId.value = null
  objectType.value = null
}

onMounted(() => {
  getParams()
})

function getParams() {
  const urlParams = new URLSearchParams(window.location.search)

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
      objectId.value = body.id
      objectType.value = model
    })
    .catch(() => {})
}

</script>

<style scoped>

</style>
