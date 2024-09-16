<template>
  <div class="field">
    <div
      v-if="containerItem.objectId"
      class="horizontal-left-content gap-small"
    >
      <p>{{ containerItem.label }}</p>
      <RadialAnnotator :global-id="containerItem.objectGlobalId" />
      <VBtn
        v-if="!containerItem.id"
        circle
        color="primary"
        @click="unsetContainerObject"
      >
        <VIcon
          name="undo"
          small
        />
      </VBtn>
    </div>
    <div v-else>
      <ul class="no_bullets">
        <li
          v-for="(_, type) in TYPES"
          :key="type"
        >
          <label>
            <input
              type="radio"
              :value="type"
              v-model="selectedType"
            />
            {{ type }}
          </label>
        </li>
      </ul>
      <VAutocomplete
        class="margin-small-top"
        param="term"
        label="label"
        autofocus
        :url="TYPES[selectedType].autocomplete"
        :placeholder="TYPES[selectedType].placeholder"
        @get-item="setContainedObject"
      />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { COLLECTION_OBJECT, CONTAINER, EXTRACT } from '@/constants'
import { CollectionObject, Extract, Container } from '@/routes/endpoints'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { CONTAINER_PARAMETERS } from '../../constants'

const TYPES = {
  [COLLECTION_OBJECT]: {
    autocomplete: '/collection_objects/autocomplete',
    placeholder: 'Search a collection object...',
    service: CollectionObject
  },
  [CONTAINER]: {
    autocomplete: '/containers/autocomplete',
    placeholder: 'Search a container...',
    service: Container
  },
  [EXTRACT]: {
    autocomplete: '/extracts/autocomplete',
    placeholder: 'Search an extract...',
    service: Extract
  }
}

const containerItem = defineModel({
  type: Object,
  required: true
})

const selectedType = ref(COLLECTION_OBJECT)

function setContainedObject({ id }) {
  const { service } = TYPES[selectedType.value]

  service.find(id, CONTAINER_PARAMETERS).then(({ body }) => {
    Object.assign(containerItem.value, {
      objectId: id,
      objectType: selectedType.value,
      objectGlobalId: body.global_id,
      label: body.container_label,
      isUnsaved: true
    })
  })
}

function unsetContainerObject() {
  Object.assign(containerItem.value, {
    objectId: null,
    objectType: null,
    label: null,
    isUnsaved: true
  })
}
</script>
