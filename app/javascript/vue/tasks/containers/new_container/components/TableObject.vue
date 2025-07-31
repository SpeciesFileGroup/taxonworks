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
import { Extract, CollectionObject, Container } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { URLParamsToJSON } from '@/helpers'
import { useContainerStore, useObjectStore } from '../store'
import { makeContainerItem } from '../adapters'
import { CONTAINER_PARAMETERS } from '../constants'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { LinkerStorage } from '@/shared/Filter/utils'
import { EXTRACT, COLLECTION_OBJECT, CONTAINER } from '@/constants'
import { onBeforeMount } from 'vue'

const SERVICES = {
  [QUERY_PARAM[COLLECTION_OBJECT]]: CollectionObject,
  [QUERY_PARAM[EXTRACT]]: Extract,
  [QUERY_PARAM[CONTAINER]]: Container
}

const store = useContainerStore()
const objectStore = useObjectStore()
const isLoading = ref(false)

const list = computed(() =>
  objectStore.objects.filter((item) => !store.getContainerItemByObject(item))
)

function makeObjectItem(obj) {
  return {
    ...makeContainerItem(obj),
    id: null,
    objectId: obj.id,
    objectType: obj.base_class,
    objectGlobalId: obj.global_id,
    label: obj.container_label,
    isUnsaved: true
  }
}

function addContainerItem(item) {
  store.addContainerItem({ ...item, isUnsaved: true })
}

function getObjectsFromParameters() {
  const parameters = {
    ...URLParamsToJSON(window.location.href),
    ...LinkerStorage.getParameters()
  }

  LinkerStorage.removeParameters()

  const queryParam = Object.keys(parameters).find((param) =>
    Object.values(QUERY_PARAM).includes(param)
  )
  const queryValue = parameters[queryParam]

  isLoading.value = !!queryParam

  if (queryParam) {
    const payload = {
      ...CONTAINER_PARAMETERS,
      ...queryValue,
      per: 200
    }

    SERVICES[queryParam]
      .filter(payload)
      .then(({ body }) => {
        objectStore.objects.push(...body.map(makeObjectItem))
      })
      .finally(() => {
        isLoading.value = false
      })
  }
}

onBeforeMount(getObjectsFromParameters)
</script>

<style scoped>
td {
  max-width: 200px;
  overflow-x: hidden;
  text-overflow: ellipsis;
}
</style>
