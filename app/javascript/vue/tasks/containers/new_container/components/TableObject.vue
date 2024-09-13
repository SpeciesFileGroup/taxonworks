<template>
  <table
    v-if="list.length"
    class="table-striped full_width"
  >
    <thead>
      <tr>
        <th class="column-object">Objects (Out)</th>
        <th class="w-2">
          <VBtn
            color="primary"
            :disabled="!store.container.id"
            @click="() => list.forEach(addContainerItem)"
          >
            Add all
          </VBtn>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id"
      >
        <td v-html="item.label" />
        <td>
          <div class="horizontal-right-content gap-small">
            <VBtn
              color="primary"
              circle
              :disabled="!store.container.id"
              @click="() => addContainerItem(item)"
            >
              <VIcon
                name="plus"
                x-small
              />
            </VBtn>
            <VBtn
              color="primary"
              circle
              @click="() => objectStore.removeFromList(item)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
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
import { useContainerStore, useObjectStore } from '../store'
import { makeContainerItem } from '../adapters'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const store = useContainerStore()
const objectStore = useObjectStore()
const isModalVisible = ref(false)
const isLoading = ref(false)
const promises = []

const list = computed(() =>
  objectStore.objects.filter((item) => !store.getContainerItemByObject(item))
)

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
    responses.map(({ body }) => {
      objectStore.objects.push(...body.map(makeObjectItem))
    })
  })
  .finally(() => (isLoading.value = false))

function makeObjectItem(obj) {
  return {
    ...makeContainerItem(obj),
    id: null,
    objectId: obj.id,
    objectType: obj.base_class,
    label: obj.object_label,
    isUnsaved: true
  }
}

function addContainerItem(item) {
  store.addContainerItem({ ...item, isUnsaved: true })
}
</script>

<style scoped>
td {
  max-width: 200px;
  overflow-x: hidden;
  text-overflow: ellipsis;
}
</style>
