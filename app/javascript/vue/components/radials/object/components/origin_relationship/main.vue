<template>
  <div>
    <div class="direction margin-medium-bottom">
      <div class="direction-wording">
        <div>
          <span
            v-if="originOf"
            v-html="originOf"
          />
          <span v-else>[Select an origin]</span>
        </div>

        <div class="margin-medium-left inline">
          <span
            >is the origin of<br />
            <div class="margin-medium-left">
              <span
                v-if="originFor"
                v-html="originFor"
              />
              <span v-else>[Select an endpoint]</span>
            </div>
          </span>
        </div>
      </div>
      <div class="margin-small-right">
        <VBtn
          color="primary"
          circle
          @click="flip = !flip"
        >
          <VIcon
            name="swap"
            x-small
          />
        </VBtn>
      </div>
    </div>

    <div>
      <div>
        {{ originEndpoint }}:
        <select v-model="type">
          <option :value="null">Select type</option>
          <option
            v-for="(key) in Object.keys(typeList).sort()"
            :key="key"
            :value="key"
          >
            {{ key }}
          </option>
        </select>
      </div>

      <div
        v-if="type"
        class="margin-large-top"
      >
        <div v-if="offerCreate">
          <VBtn
            v-if="!showingCreate"
            color="primary"
            @click="() => (showingCreate = true)"
          >
            New
          </VBtn>

          or
        </div>

        <smart-selector
          :model="modelSelected"
          :target="metadata.object_type"
          @selected="(obj) => setObject(obj)"
        />
      </div>
    </div>

    <div class="margin-large-top margin-large-bottom">
      <VBtn
        color="create"
        :disabled="!objective"
        @click="createOrigin"
      >
        Create
      </VBtn>
    </div>

    <fieldset
      v-if="Object.keys(originForList).length > 0"
      class="margin-large-bottom"
    >
      <legend>Endpoints</legend>
      <VSpinner
        v-if="loadingNewObjects"
      />
      <h3 class="no-flex"><span v-html="props.metadata.object_tag" />&nbsp;is the origin of:</h3>
      <RelationshipsTable
        v-if="newObjectsList.length > 0"
        v-model="newObjectsList"
        t="new"
        @remove="(element) => removeOrigin(element, 'new')"
        @sort="(event) => onSortable(event)"
        class="margin-medium-top full_width"
      />
      <p
        v-else
        class="margin-xlarge-left"
      >
        <i>No relationships.</i>
      </p>
    </fieldset>

    <fieldset v-if="Object.keys(originatesFromList).length > 0">
      <legend>Origins</legend>
      <VSpinner
        v-if="loadingOldObjects"
      />
      <h3 class="no-flex"><span class="blank d-inline-block" />&nbsp;is the origin of&nbsp;<span v-html="props.metadata.object_tag" />:</h3>
      <RelationshipsTable
        v-if="oldObjectsList.length > 0"
        v-model="oldObjectsList"
        t="old"
        @remove="(element) => removeOrigin(element, 'old')"
        class="margin-medium-top full_width"
      />
      <p
        v-else
        class="margin-xlarge-left"
      >
        <i>No relationships.</i>
      </p>
    </fieldset>

    <VModal
      v-if="showingCreate"
      @close="showingCreate = false"
    >
      <template #header>
        Create new {{ type }}
      </template>

      <template #body>
        <component
          :is="SLICES_WITH_CREATE.origin_relationships[type]"
          :origin-object-id="objectId"
          :origin-object-type="objectType"
          @create="(obj) => {
            setObject(obj)
            showingCreate = false
          }"
        />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { OriginRelationship } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import { ref, computed, onMounted, watch } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import { SLICES_WITH_CREATE } from '../../constants/slices'
import SmartSelector from '@/components/ui/SmartSelector'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VModal from '@/components/ui/Modal'
import RelationshipsTable from './components/relationshipsTable.vue'
import { addToArray, removeFromArray } from '@/helpers'

const controllerRoute = {
  AssertedDistribution: 'asserted_distributions',
  Extract: 'extracts',
  Lot: 'collection_objects',
  Sequence: 'sequences',
  Specimen: 'collection_objects',
  Sound: 'sounds',
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

const originForList = props.metadata.endpoints.origin_relationships.origin_for
const originatesFromList = props.metadata.endpoints.origin_relationships.originates_from
const typeList = computed(() => flip.value ? originatesFromList : originForList)

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

const flip = ref(false)
const type = ref(null)
const objective = ref(null)
const showingCreate = ref(false)
const loadingNewObjects = ref(false)
const loadingOldObjects = ref(false)
const oldObjectsList = ref([])
const newObjectsList = ref([])

// Only offer to create a new anatomical_part if we know what its origin would
// be (necessary for validations - anatomical_part chains are *always* built
// from the top down).
const offerCreate = computed(() => Object.keys(SLICES_WITH_CREATE.origin_relationships).includes(type.value) && flip.value == false)

const originEndpoint = computed(() => flip.value ? 'Origin' : 'Endpoint')
const originOf = computed(() => {
  return !flip.value ? props.metadata.object_tag : objective.value?.object_tag
})

const originFor = computed(() => {
  return flip.value ? props.metadata.object_tag : objective.value?.object_tag
})

const modelSelected = computed(() => controllerRoute[type.value])

watch([oldObjectsList, newObjectsList], ([newA, newB]) => {
  // This is not quite the way useSlice intends its list to be defined - compare
  // the resulting 'a little hacky' comments.
  list.value = [...newA, ...newB]
})

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
      addToList(body) // just to trigger useSlice emits (a little hacky)
      addToArray(flip.value ? oldObjectsList.value : newObjectsList.value, body)
    })
    .catch(() => {})
}

function removeOrigin(item, t) {
  OriginRelationship.destroy(item.id).then(() => {
    TW.workbench.alert.create(
      'Origin relationship was successfully destroyed.',
      'notice'
    )
    removeFromList(item) // just to trigger useSlice emits (a little hacky)
    removeFromArray(t == 'new' ? newObjectsList.value : oldObjectsList.value, item)
  })
}

function onSortable({ newIndex }) {
  const originRelationship = {
    id: newObjectsList.value[newIndex].id,
    position: newIndex
  }

  // TODO: this doesn't do what you expect when moving 0 to 1 (old 1 just
  // moves to 2).
  OriginRelationship.update(originRelationship.id, {
    origin_relationship: originRelationship
  }).then(({ body }) => {
    addToList(body)
  })
}

onMounted(() => {
  loadingNewObjects.value = true
  OriginRelationship.where({ old_object_global_id: props.globalId, extend: ['global_ids'] })
    .then(
      ({ body }) => {
        newObjectsList.value = body
      }
    )
    .catch(() => {})
    .finally(() => loadingNewObjects.value = false)

  loadingOldObjects.value = true
  OriginRelationship.where({ new_object_global_id: props.globalId, extend: ['global_ids'] })
    .then(
      ({ body }) => {
        oldObjectsList.value = body
      }
    )
    .catch(() => {})
    .finally(() => loadingOldObjects.value = false)
})
</script>

<style lang="css" scoped>
.direction {
  display: flex;
  gap: 0.5em;
  align-items: center;
}

.direction-wording {
  padding-left: 0.5em;
  padding-right: 0.5em;
  border-right: 2px solid var(--border-color);
  border-radius: var(--border-radius-small);
}

.blank {
  width: 5em;
  border-bottom: 2px solid var(--text-color);
}

.panel h3.no-flex {
  display: block;
}
</style>