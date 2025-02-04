<template>
  <div>
    <div class="margin-medium-bottom">
      <div>
        <span
          v-if="originOf"
          v-html="originOf"
        />
        <span v-else>Select a origin</span>
      </div>

      <div class="margin-medium-left inline">
        <span
          >is the origin of<br />
          <div class="margin-medium-left">
            <span
              v-if="originFor"
              v-html="originFor"
            />
            <span v-else>[Select a origin]</span>
          </div>
        </span>
        <button
          class="center-icon small-icon button circle-button button-default"
          data-icon="w-swap"
          type="button"
          @click="flip = !flip"
        >
          Flip
        </button>
      </div>
      <div class="margin-medium-left">
        <div class="margin-xlarge-left">
          a
          <select v-model="type">
            <option :value="null">Select type</option>
            <option
              v-for="(_, key) in typeList"
              :key="key"
              :value="key"
            >
              {{ key }}
            </option>
          </select>
        </div>
      </div>
    </div>
    <smart-selector
      v-if="type"
      :model="modelSelected"
      :target="metadata.object_type"
      @selected="setObject"
    />

    <div>
      <button
        type="button"
        class="button normal-input button-submit"
        :disabled="!objective"
        @click="createOrigin"
      >
        Create
      </button>
    </div>
    <table>
      <thead>
        <tr>
          <th>Old object</th>
          <th>New object</th>

          <th />
        </tr>
      </thead>
      <draggable
        class="table-entrys-list"
        tag="tbody"
        item-key="id"
        v-model="list"
        @end="onSortable"
      >
        <template #item="{ element }">
          <tr>
            <td v-html="element.old_object_object_tag" />
            <td v-html="element.new_object_object_tag" />
            <td>
              <span
                class="circle-button btn-delete"
                @click="removeOrigin(element)"
              />
            </td>
          </tr>
        </template>
      </draggable>
    </table>
  </div>
</template>

<script setup>
import { OriginRelationship } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import { ref, computed } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import SmartSelector from '@/components/ui/SmartSelector'
import Draggable from 'vuedraggable'

const controllerRoute = {
  AssertedDistribution: 'asserted_distributions',
  Extract: 'extracts',
  Lot: 'collection_objects',
  Sequence: 'sequences',
  Specimen: 'collection_objects',
  RangedLot: 'collection_objects'
}

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  globalId: {
    type: String,
    required: true
  },

  metadata: {
    type: Object,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const typeList = props.metadata.endpoints.origin_relationships.origin_for

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const flip = ref(false)
const type = ref(null)
const objective = ref(null)

const originOf = computed(() => {
  return !flip.value ? props.metadata.object_tag : objective.value?.object_tag
})

const originFor = computed(() => {
  return flip.value ? props.metadata.object_tag : objective.value?.object_tag
})

const modelSelected = computed(() => controllerRoute[type.value])

function setObject(item) {
  objective.value =
    modelSelected.value === controllerRoute.Specimen
      ? Object.assign(item, { base_class: COLLECTION_OBJECT })
      : item
}

function createOrigin() {
  const newObject = !flip.value
    ? objective.value
    : { id: props.objectId, base_class: props.objectType }
  const oldObject = flip.value
    ? objective.value
    : { id: props.objectId, base_class: props.objectType }
  const originRelationship = {
    old_object_id: oldObject.id,
    old_object_type: oldObject.base_class,
    new_object_id: newObject.id,
    new_object_type: newObject.base_class
  }

  OriginRelationship.create({
    origin_relationship: originRelationship
  })
    .then(({ body }) => {
      TW.workbench.alert.create(
        'Origin relationship was successfully created.',
        'notice'
      )
      addToList(body)
    })
    .catch(() => {})
}

function removeOrigin(item) {
  OriginRelationship.destroy(item.id).then(() => {
    TW.workbench.alert.create(
      'Origin relationship was successfully destroyed.',
      'notice'
    )
    removeFromList(item)
  })
}

function onSortable({ newIndex }) {
  const originRelationship = {
    id: list.value[newIndex].id,
    position: newIndex
  }

  OriginRelationship.update(originRelationship.id, {
    origin_relationship: originRelationship
  }).then(({ body }) => {
    addToList(body)
  })
}

OriginRelationship.where({ old_object_global_id: props.globalId }).then(
  ({ body }) => {
    list.value = body
  }
)
</script>
