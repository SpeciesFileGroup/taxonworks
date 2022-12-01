<template>
  <div>
    <label>Namespace</label>
    <div class="horizontal-left-content middle field">
      <SelectedItem
        v-if="store.namespace"
        class="full_width"
        label="label"
        :item="store.namespace"
        @unset="unsetNamespace"
      />
      <Autocomplete
        v-else
        ref="autocompleteComponent"
        class="full_width"
        url="/namespaces/autocomplete"
        param="term"
        label="label_html"
        clear-after
        autofocus
        placeholder="Search a namespace..."
        @get-item="store.namespace = $event"
      />
      <VLock
        class="margin-small-left"
        v-model="store.settings.lock.namespace"
      />
    </div>

    <div class="">
      <label>Identifier</label>
      <div class="horizontal-left-content">
        <input
          type="text"
          class="half_width"
          v-model="store.identifier"
          :data-locked="store.settings.lock.namespace"
          @input="checkIdentifier"
        >
        <label>
          <input
            v-model="store.settings.increment"
            type="checkbox"
          >
          Increment
        </label>
      </div>
      <span
        v-if="!store.namespace && store.identifier"
        style="color: red"
      >
        Namespace is needed.
      </span>
      <template v-if="store.createdIdentifiers.length">
        <span
          style="color: red"
        >Identifier already exists, and it won't be saved:</span>
        <a
          :href="store.createdIdentifiers[0].identifier_object.object_url"
          v-html="store.createdIdentifiers[0].identifier_object.object_tag"
        />
      </template>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { useStore } from '../store/useStore'
import SelectedItem from './SelectedItem.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import VLock from 'components/ui/VLock/index.vue'

const autocompleteComponent = ref(null)
const store = useStore()
const DELAY = 1000
let timeoutRequest

function checkIdentifier () {
  clearTimeout(timeoutRequest)

  timeoutRequest = setTimeout(() => {
    store.getIdentifiers()
  }, DELAY)
}

function unsetNamespace () {
  store.namespace = undefined
  store.identifier = undefined
}

onMounted(() => {
  setTimeout(() => autocompleteComponent.value.setFocus(), 250)
})

watch(
  () => store.settings.lock.namespace,
  newVal => {
    if (!newVal) {
      unsetNamespace()
    }
  }
)

</script>
