<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th class="w-2">ID</th>
        <th>Object</th>
        <th
          v-for="item in store.predicates"
          :key="item.id"
        >
          {{ item.label }}
        </th>
        <th class="w-2">
          <VBtn
            color="create"
            :disabled="!store.hasUnsaved"
            @click="store.saveDataAttributes"
            >Save all</VBtn
          >
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(item, index) in store.objects"
        :key="item.id"
      >
        <td>{{ item.id }}</td>
        <td v-html="item.label" />
        <template
          v-for="predicate in store.predicates"
          :key="predicate.id"
        >
          <td>
            <input
              v-for="da in store.getDataAttributesByObject({
                objectType: item.type,
                objectId: item.id,
                predicateId: predicate.id
              })"
              :key="da.uuid"
              type="text"
              v-model="da.value"
              @change="() => (da.isUnsaved = true)"
              @paste="
                (event) => {
                  event.preventDefault(),
                    store.pasteValue({
                      text: event.clipboardData.getData('text/plain'),
                      position: index,
                      predicateId: predicate.id
                    })
                }
              "
            />
          </td>
        </template>
        <td>
          <VBtn
            color="create"
            :disabled="
              !store.objectHasUnsaved({
                objectId: item.id,
                objectType: item.type
              })
            "
            @click="
              () =>
                store.saveDataAttributesFor({
                  objectId: item.id,
                  objectType: item.type
                })
            "
          >
            Save
          </VBtn>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import useStore from '../store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'

const store = useStore()
</script>
