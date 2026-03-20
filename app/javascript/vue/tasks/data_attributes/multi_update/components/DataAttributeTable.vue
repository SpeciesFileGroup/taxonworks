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
              <th
                class="position-sticky"
                colspan="2"
              >
                <div class="flex-separate middle">
                  <label>
                    <input
                      type="checkbox"
                      v-model="selectAllProperties"
                    />
                    Attributes
                  </label>
                </div>
              </th>
              <th
                v-if="store.predicates.length"
                :colspan="store.predicates.length"
                class="position-sticky cell-left-border"
              >
                <div class="flex-separate middle">
                  <label>
                    <input
                      type="checkbox"
                      v-model="selectAllPredicates"
                    />
                    Predicates
                  </label>
                  <div class="horizontal-right-content middle gap-small">
                    <VBtn
                      color="primary"
                      circle
                      title="Clear columns"
                      @click="
                        () =>
                          store.predicates.forEach((predicate) =>
                            store.clearColumn(predicate)
                          )
                      "
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
                          store.predicates.forEach((p) =>
                            store.reloadDataAttributes(p.id)
                          )
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
                      @click="
                        () =>
                          store.predicates.forEach((p) =>
                            store.removePredicate(p)
                          )
                      "
                    >
                      <VIcon
                        name="trash"
                        x-small
                      />
                    </VBtn>
                  </div>
                </div>
              </th>
              <th class="position-sticky w-2">
                <CopyToClipboard
                  :predicate-ids="predicateIds"
                  :attributes="attributes"
                />
              </th>
            </tr>
            <tr>
              <th
                v-for="(label, attr) in OBJECT_HEADER"
                class="position-sticky w-2"
                :key="attr"
              >
                <div class="flex-separate middle gap-small">
                  <label class="flex-row middle gap-xsmall cursor-pointer">
                    <input
                      type="checkbox"
                      v-model="attributes"
                      :value="attr"
                    />
                    {{ label }}
                  </label>
                  <VBtn
                    color="primary"
                    circle
                    title="Sort column"
                    @click="() => sortByAttribute(attr)"
                  >
                    <VIcon
                      name="alphabeticalSort"
                      x-small
                      title="Sort alphabetically"
                    />
                  </VBtn>
                </div>
              </th>

              <th
                v-for="(predicate, index) in store.predicates"
                :key="predicate.id"
                :class="[
                  'position-sticky w-2',
                  index === 0 && 'cell-left-border'
                ]"
              >
                <div class="flex-separate gap-small">
                  <label class="flex-row middle gap-xsmall cursor-pointer">
                    <input
                      type="checkbox"
                      :value="predicate.id"
                      v-model="predicateIds"
                    />
                    {{ predicate.label }}
                  </label>
                  <div class="horizontal-right-content middle gap-small">
                    <VBtn
                      color="primary"
                      circle
                      title="Fill column"
                      @click="() => fillColumn(predicate)"
                    >
                      <VIcon
                        name="pencil"
                        x-small
                      />
                    </VBtn>

                    <VBtn
                      color="primary"
                      circle
                      title="Sort column"
                      @click="() => sortByPredicate(predicate.id)"
                    >
                      <VIcon
                        name="alphabeticalSort"
                        x-small
                        title="Sort alphabetically"
                      />
                    </VBtn>

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
                      title="Reload column"
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
              <td
                class="full_width"
                v-html="item.label"
              />
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
                      :class="[
                        'flex-auto',
                        da.isUnsaved && da.value.length && 'highlight-unsaved',
                        da.isUnsaved &&
                          da.id &&
                          !da.value.length &&
                          'highlight-destroy'
                      ]"
                      type="text"
                      v-model="da.value"
                      @change="
                        () => (da.isUnsaved = (!da.id && da.value) || da.id)
                      "
                      @paste="
                        (event) => {
                          ;(event.preventDefault(),
                            store.pasteValue({
                              text: event.clipboardData.getData('text/plain'),
                              objectId: item.id,
                              predicateId: predicate.id
                            }))
                        }
                      "
                    />
                  </div>
                </td>
              </template>
              <td class="w-2">
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
  <EditColumn ref="editColumnRef" />
</template>

<script setup>
import { computed, ref } from 'vue'
import { sortArray } from '@/helpers/arrays.js'
import useStore from '../store/store.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VirtualScroller from '@/components/ui/Table/VirtualScroller.vue'
import CopyToClipboard from './CopyToClipboard.vue'
import EditColumn from '../../field_synchronize/components/Table/EditColumn.vue'

const OBJECT_HEADER = {
  id: 'ID',
  plainLabel: 'Label'
}

const store = useStore()

const editColumnRef = ref(null)
const predicateIds = ref([])
const attributes = ref([])

const ascending = ref(false)

function sortByAttribute(attr) {
  store.sortObjects(
    sortArray(store.objects, attr, ascending.value, { stripHtml: true })
  )
  ascending.value = !ascending.value
}

function sortByPredicate(predicateId) {
  const sorted = store.objects.slice().sort((a, b) => {
    const daA = store.getDataAttributesByObject({
      objectType: a.type,
      objectId: a.id,
      predicateId
    })
    const daB = store.getDataAttributesByObject({
      objectType: b.type,
      objectId: b.id,
      predicateId
    })

    const valA = daA.length ? daA[0].value : ''
    const valB = daB.length ? daB[0].value : ''

    const result = valA.localeCompare(valB, undefined, {
      numeric: true,
      sensitivity: 'base'
    })

    return ascending.value ? result : -result
  })

  store.sortObjects(sorted)
  ascending.value = !ascending.value
}

async function fillColumn(predicate) {
  try {
    const payload = await editColumnRef.value.show({
      title: predicate.label,
      btnColor: 'primary'
    })

    if (payload) {
      store.objects.forEach((obj) => {
        const dataAttributes = store.getDataAttributesByObject({
          objectType: obj.type,
          objectId: obj.id,
          predicateId: predicate.id
        })

        dataAttributes.forEach((da) => {
          if (payload.replace || !da.value) {
            da.value = payload.value
            da.isUnsaved = !!da.id || !!payload.value
          }
        })
      })
    }
  } catch {
    /* empty */
  }
}

const selectAllPredicates = computed({
  get: () =>
    store.predicates.length &&
    predicateIds.value.length === store.predicates.length,

  set: (value) =>
    (predicateIds.value = value ? store.predicates.map((p) => p.id) : [])
})

const selectAllProperties = computed({
  get: () => attributes.value.length === Object.keys(OBJECT_HEADER).length,
  set: (value) => (attributes.value = value ? Object.keys(OBJECT_HEADER) : [])
})
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

  th:last-child {
    border-left: 1px solid var(--border-color);
  }
}

.cell-left-border {
  border-left: 3px var(--border-color) solid;
}

.highlight-unsaved {
  outline: 2px solid var(--color-create);
}

.highlight-destroy {
  outline: 2px solid var(--color-destroy);
}
</style>
