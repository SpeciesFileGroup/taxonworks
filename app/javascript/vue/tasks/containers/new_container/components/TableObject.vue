<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th class="column-object">Object</th>
        <th>
          <VBtn
            color="create"
            :disabled="!store.container.id"
          >
            Create container items
          </VBtn>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
      >
        <td v-html="item.object_tag" />
        <td>
          <VBtn color="create">Create</VBtn>
        </td>
      </tr>
    </tbody>
  </table>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
</template>

<script setup>
import { Extract, CollectionObject } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { URLParamsToJSON } from '@/helpers'
import { useContainerStore } from '../store'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { makeContainerItem } from '../adapters'

const store = useContainerStore()
const objects = ref([])
const list = computed(() =>
  objects.value.filter(store.getContainerItemByObject)
)
const isModalVisible = ref(false)
const isLoading = ref(false)
const promises = []

const { extract_id: extractIds, collection_object_id: collectionObjectIds } =
  URLParamsToJSON(window.location.href)

if (extractIds) {
  promises.push(Extract.filter({ extract_id: extractIds }))
}

if (collectionObjectIds) {
  promises.push(
    CollectionObject.filter({ collection_object_id: collectionObjectIds })
  )
}

isModalVisible.value = !!(extractIds || collectionObjectIds)

Promise.all(promises)
  .then((responses) => {
    responses.map(({ body }) => objects.value.push(...body))
  })
  .finally(() => (isLoading.value = false))

function addContainer(obj) {
  const item = {
    ...makeContainerItem(obj),
    objectId: obj.id,
    objectType: obj.base_class
  }

  store.addContainerItem(item)
}
</script>

<style scoped>
td {
  max-width: 200px;
  overflow-x: hidden;
  text-overflow: ellipsis;
}
</style>
