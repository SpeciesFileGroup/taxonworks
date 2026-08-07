<template>
  <div class="flex-col gap-small">
    <div>
      <label>Namespace</label>
      <div class="horizontal-left-content middle gap-small">
        <SelectedItem
          v-if="store.namespace"
          class="full_width"
          label="label"
          :item="store.namespace"
          @unset="unsetNamespace"
        />
        <VAutocomplete
          v-else
          ref="autocompleteComponent"
          class="full_width"
          url="/namespaces/autocomplete"
          param="term"
          label="label_html"
          clear-after
          placeholder="Search a namespace..."
          :input-attributes="{
            'data-locked': store.settings.lock.namespace
          }"
          @get-item="(item) => (store.namespace = item)"
        />
        <WidgetNamespace
          @create="
            (item) => (store.namespace = { id: item.id, label: item.name })
          "
        />
        <VLock v-model="store.settings.lock.namespace" />
      </div>
    </div>
    <div>
      <div class="horizontal-left-content align-end gap-small">
        <div class="label-above full_width">
          <label>{{ isRange ? 'Identifier start' : 'Identifier' }}</label>
          <input
            type="text"
            class="full_width"
            v-model="store.identifier"
            :data-locked="store.settings.lock.namespace"
            @input="checkIdentifier"
          />
        </div>
        <div
          v-if="isRange"
          class="label-above full_width"
        >
          <label>Identifier end</label>
          <input
            disabled
            type="text"
            class="full_width"
            :value="identifierEnd"
          />
        </div>
        <label class="flex-row middle">
          <input
            v-model="store.settings.increment"
            type="checkbox"
          />
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
        <span style="color: red"
          >Identifier already exists, and it won't be saved:</span
        >
        <a
          :href="store.createdIdentifiers[0].identifier_object.object_url"
          v-html="store.createdIdentifiers[0].identifier_object.object_tag"
        />
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import { useStore } from '../store/useStore'
import incrementIdentifier from '@/tasks/digitize/helpers/incrementIdentifier'
import SelectedItem from './SelectedItem.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VLock from '@/components/ui/VLock/index.vue'
import WidgetNamespace from '@/components/ui/Widget/WidgetNamespace.vue'

const autocompleteComponent = ref(null)
const store = useStore()
const DELAY = 1000
let timeoutRequest

const isRange = computed(() => store.createTotal > 1)
const identifierEnd = computed(() =>
  incrementIdentifier(store.identifier, store.createTotal - 1)
)

function checkIdentifier() {
  clearTimeout(timeoutRequest)

  timeoutRequest = setTimeout(() => {
    store.getIdentifiers()
  }, DELAY)
}

function unsetNamespace() {
  store.namespace = undefined
  store.identifier = undefined
}

onMounted(() => {
  nextTick(() => autocompleteComponent.value?.setFocus())
})

watch(
  () => store.settings.lock.namespace,
  (newVal) => {
    if (!newVal) {
      unsetNamespace()
    }
  }
)
</script>
