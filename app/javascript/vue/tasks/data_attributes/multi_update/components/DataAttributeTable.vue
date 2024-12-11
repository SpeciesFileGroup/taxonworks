<template>
  <div class="full_width">
    <VirtualScroller
      :items="store.objects"
      :item-height="41"
      class="table-scroller"
    >
      <template #default="{ items }">
        <table class="table-striped table-data-attributes full_width">
          <thead>
            <tr>
              <th class="position-sticky w-2">ID</th>
              <th class="position-sticky">Object</th>
              <th
                v-for="item in store.predicates"
                :key="item.id"
                class="position-sticky w-2"
              >
                {{ item.label }}
              </th>
              <th class="position-sticky w-2">
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
              v-for="(item, index) in items"
              :key="item.id"
            >
              <td>{{ item.id }}</td>
              <td v-html="item.label" />
              <template
                v-for="predicate in store.predicates"
                :key="predicate.id"
              >
                <td>
                  <div class="horizontal-left-content gap-medium">
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
                  </div>
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
    </VirtualScroller>
  </div>
</template>

<script setup>
import useStore from '../store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VirtualScroller from '@/components/ui/Table/VirtualScroller.vue'

const store = useStore()
</script>

<style scoped>
.table-scroller {
  width: 100%;
  height: calc(90vh - 100px);
  overflow: auto;
  overflow-anchor: none;
}

.table-data-attributes {
  th {
    top: 0;
    z-index: 2101;
    text-wrap: nowrap;
  }
}
</style>
