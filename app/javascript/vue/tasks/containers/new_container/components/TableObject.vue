<template>
  <table
    v-if="list.length"
    class="table-striped full_width"
  >
    <thead>
      <tr>
        <th class="column-object">Objects</th>
        <th class="w-2">
          <VBtn
            color="primary"
            @click="() => list.forEach(addToContainerItems)"
          >
            Add to container
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
          <div class="horizontal-right-content">
            <VBtn
              color="primary"
              @click="() => addToContainerItems(item)"
              >Add</VBtn
            >
          </div>
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
import { makeContainerItem } from '../adapters'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const store = useContainerStore()
const objects = ref([])
const list = computed(() =>
  objects.value.filter(
    (item) =>
      !store.getContainerItemByObject({
        objectId: item.id,
        objectType: item.base_class
      })
  )
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

function addToContainerItems(obj) {
  const item = Object.assign(makeContainerItem(obj), {
    id: null,
    objectId: obj.id,
    objectType: obj.base_class,
    label: obj.object_label,
    isUnsaved: true
  })

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
