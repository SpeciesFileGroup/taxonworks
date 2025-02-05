<template>
  <div class="full_width overflow-x-auto">
    <VirtualScroller
      :items="store.objects"
      :item-height="41"
      class="table-scroller"
    >
      <template #default="{ items }">
        <table class="table-striped table-data-attributes full_width">
          <thead>
            <tr>
              <th colspan="2">
                <CopyToClipboard
                  :predicate-ids="predicateIds"
                  :attributes="attributes"
                />
              </th>
              <th :colspan="store.predicates.length + 1"></th>
            </tr>
            <tr>
              <th
                v-for="(label, attr) in OBJECT_HEADER"
                class="position-sticky w-2"
                :key="attr"
              >
                <label class="flex-row middle gap-xsmall cursor-pointer">
                  <input
                    type="checkbox"
                    v-model="attributes"
                    :value="attr"
                  />
                  {{ label }}
                </label>
              </th>

              <th
                v-for="(predicate, index) in store.predicates"
                :key="predicate.id"
                :class="[
                  'position-sticky w-2',
                  index === 0 && 'cell-left-border'
                ]"
              >
                <div class="horizontal-left-content gap-small">
                  <label class="flex-row middle gap-xsmall cursor-pointer">
                    <input
                      type="checkbox"
                      :value="predicate.id"
                      v-model="predicateIds"
                    />
                    {{ predicate.label }}
                  </label>

                  <VBtn
                    color="primary"
                    circle
                    title="Clear column"
                    @click="() => store.clearColumn(predicate)"
                  >
                    <VIcon
                      name="eraser"
                      x-small
                      title="Clear column"
                    />
                  </VBtn>

                  <VBtn
                    color="primary"
                    circle
                    title="Reload data attributes"
                    @click="
                      () => {
                        store.reloadDataAttributes(predicate.id)
                      }
                    "
                  >
                    <VIcon
                      name="undo"
                      x-small
                      title="Reload data attributes"
                    />
                  </VBtn>

                  <VBtn
                    color="primary"
                    circle
                    @click="() => store.removePredicate(predicate)"
                  >
                    <VIcon
                      name="trash"
                      x-small
                    />
                  </VBtn>
                </div>
              </th>
              <th class="position-sticky w-2">
                <VBtn
                  color="create"
                  :disabled="!store.hasUnsaved"
                  @click="store.saveDataAttributes"
                >
                  Save all ({{
                    store.dataAttributes.filter((item) => item.isUnsaved)
                      .length
                  }})
                </VBtn>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in items"
              :key="item.id"
              class="contextMenuCells"
            >
              <td>{{ item.id }}</td>
              <td v-html="item.label" />
              <template
                v-for="(predicate, index) in store.predicates"
                :key="predicate.id"
              >
                <td :class="{ 'cell-left-border': index === 0 }">
                  <div class="horizontal-left-content gap-medium">
                    <input
                      v-for="da in store.getDataAttributesByObject({
                        objectType: item.type,
                        objectId: item.id,
                        predicateId: predicate.id
                      })"
                      :key="da.uuid"
                      class="flex-auto"
                      type="text"
                      v-model="da.value"
                      @change="() => (da.isUnsaved = true)"
                      @paste="
                        (event) => {
                          event.preventDefault(),
                            store.pasteValue({
                              text: event.clipboardData.getData('text/plain'),
                              objectId: item.id,
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
import { ref } from 'vue'
import useStore from '../store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VirtualScroller from '@/components/ui/Table/VirtualScroller.vue'
import CopyToClipboard from './CopyToClipboard.vue'

const OBJECT_HEADER = {
  id: 'ID',
  plainLabel: 'Label'
}

const store = useStore()

const predicateIds = ref([])
const attributes = ref([])
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

  td {
    white-space: nowrap;
  }
}

.cell-left-border {
  border-left: 3px #eaeaea solid;
}
</style>
