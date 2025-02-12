<template>
  <NavBar>
    <div
      v-if="store.fieldOccurrence"
      class="flex-separate middle"
    >
      <span v-html="store.fieldOccurrence.object_tag" />
      <div class="horizontal-right-content">
        <ul class="context-menu">
          <li>
            <RadialAnnotator
              :global-id="store.fieldOccurrence.global_id"
              @create="handleRadialCreate"
              @delete="handleRadialDelete"
              @update="handleRadialUpdate"
            />
          </li>
          <li>
            <RadialObject :global-id="store.fieldOccurrence.global_id" />
          </li>
          <li>
            <VBtn
              circle
              color="primary"
              title="Edit field occurrence"
              @click="openEditFieldOccurrence(store.fieldOccurrence.id)"
            >
              <VIcon
                x-small
                title="Edit field occurrence"
                name="pencil"
              />
            </VBtn>
          </li>
          <li>
            <RadialNavigator :global-id="store.fieldOccurrence.global_id" />
          </li>
        </ul>
      </div>
    </div>
    <VAutocomplete
      v-else
      class="autocomplete"
      url="/field_occurrences/autocomplete"
      placeholder="Search a field occurrence"
      param="term"
      label="label_html"
      clear-after
      @get-item="(item) => emit('select', item.id)"
    />
  </NavBar>
</template>

<script setup>
import { addToArray, removeFromArray } from '@/helpers'
import { DEPICTION, IDENTIFIER } from '@/constants'
import { RouteNames } from '@/routes/routes'
import useStore from '../store/store.js'
import VBtn from '@/components/ui/VBtn'
import VIcon from '@/components/ui/VIcon'
import NavBar from '@/components/layout/NavBar.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import useDepictionStore from '../store/depictions.js'
import useIdentifierStore from '../store/identifiers.js'

const emit = defineEmits(['select'])

const store = useStore()
const depictionStore = useDepictionStore()
const identifierStore = useIdentifierStore()

const openEditFieldOccurrence = (id) => {
  window.open(
    `${RouteNames.NewFieldOccurrence}?field_occurrence_id=${id}`,
    '_self'
  )
}

function handleRadialCreate({ item }) {
  switch (item.base_class) {
    case DEPICTION:
      addToArray(depictionStore.depictions, item)
      break

    case IDENTIFIER:
      addToArray(identifierStore.identifiers, item)
      break
  }
}

function handleRadialDelete({ item }) {
  switch (item.base_class) {
    case DEPICTION:
      removeFromArray(depictionStore.depictions, item)
      break
    case IDENTIFIER:
      removeFromArray(identifierStore.identifiers, item)
      break
  }
}

function handleRadialUpdate({ item }) {
  switch (item.base_class) {
    case DEPICTION:
      addToArray(depictionStore.depictions, item)
      break
  }
}
</script>
