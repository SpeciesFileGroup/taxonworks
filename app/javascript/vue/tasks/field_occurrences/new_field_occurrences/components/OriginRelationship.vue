<template>
  <BlockLayout>
    <template #header>
      <h3>Origin relationships</h3>
    </template>
    <template #body>
      <div class="margin-medium-bottom">
        <div class="inline">
          <span
            >Is the origin of<br />
            <div class="margin-medium-left">
              <span
                v-if="objective"
                v-html="objective.object_tag"
              />
              <span v-else>[Select a origin]</span>
            </div>
          </span>
        </div>
        <div class="margin-medium-left">
          <div class="margin-medium-left">
            a
            <select v-model="type">
              <option :value="null">Select type</option>
              <option
                v-for="item in Object.keys(TYPES)"
                :key="item"
                :value="item"
              >
                {{ item }}
              </option>
            </select>
          </div>
        </div>
      </div>
      <SmartSelector
        v-if="type"
        :model="modelSelected"
        :target="FIELD_OCCURRENCE"
        @selected="setObject"
      />

      <div>
        <VBtn
          medium
          color="primary"
          :disabled="!objective"
          @click="
            () =>
              store.add({
                uuid: randomUUID(),
                objectiveId: objective.id,
                objectiveType: objective.base_class,
                label: objective.object_tag
              })
          "
        >
          Add
        </VBtn>
      </div>
      <table class="full_width table-striped">
        <thead>
          <tr>
            <th></th>
            <th></th>
            <th />
          </tr>
        </thead>
        <VDraggable
          class="table-entrys-list"
          tag="tbody"
          item-key="id"
          v-model="store.originRelationships"
          @end="onSortable"
        >
          <template #item="{ element }">
            <tr>
              <td v-html="element.label" />
              <td />
              <td>
                <VBtn
                  circle
                  color="destroy"
                  @click="store.remove(element)"
                >
                  <VIcon
                    name="trash"
                    x-small
                  />
                </VBtn>
              </td>
            </tr>
          </template>
        </VDraggable>
      </table>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import { randomUUID } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import useOriginRelationshipStore from '../store/originRelationships.js'
import SmartSelector from '@/components/ui/SmartSelector'
import VDraggable from 'vuedraggable'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { FIELD_OCCURRENCE } from '@/constants/modelTypes.js'

const TYPES = {
  AssertedDistribution: 'asserted_distributions',
  Extract: 'extracts',
  Lot: 'collection_objects',
  Sequence: 'sequences',
  Specimen: 'collection_objects',
  Sound: 'sounds'
}

const store = useOriginRelationshipStore()

const type = ref(null)
const objective = ref(null)

const modelSelected = computed(() => TYPES[type.value])

function setObject(item) {
  objective.value = item
}

function onSortable({ newIndex }) {
  const item = store.originRelationships[newIndex].id

  store.add({
    ...item,
    position: newIndex
  })
}
</script>
