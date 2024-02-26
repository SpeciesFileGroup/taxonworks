<template>
  <div>
    <div class="horizontal-left-content align-start">
      <div
        class="flex-wrap-column full_width"
        v-for="(column, key, index) in componentsOrder"
        :class="{ 'margin-medium-right': index < lastColumn }"
        :key="key"
      >
        <h2 v-if="TITLE_SECTION[key]">{{ TITLE_SECTION[key] }}</h2>
        <draggable
          class="full_width"
          v-model="componentsOrder[key]"
          :item-key="(element) => element"
          :disabled="!sortable"
          @end="updatePreferences"
        >
          <template #item="{ element }">
            <component
              v-if="!exclude.includes(element)"
              class="separate-bottom"
              v-model="store.collectingEvent"
              :components-order="componentsOrder"
              :is="VueComponents[element]"
            />
          </template>
        </draggable>
      </div>
    </div>
  </div>
</template>

<script setup>
import Draggable from 'vuedraggable'
import useStore from './store/collectingEvent.js'
import { User } from '@/routes/endpoints'
import { ref, computed, watch } from 'vue'
import {
  ComponentMap,
  ComponentParse,
  ComponentVerbatim,
  VueComponents
} from './const/components'

const KEY_STORAGE = 'form::collectingEvent::componentsOrder'
const TITLE_SECTION = {
  componentVerbatim: 'Verbatim',
  componentParse: 'Parsed'
}

defineProps({
  sortable: {
    type: Boolean,
    default: false
  },

  exclude: {
    type: Array,
    default: () => []
  }
})

const store = useStore()
const preferences = ref({})
const componentsOrder = ref({
  componentVerbatim: Object.keys(ComponentVerbatim),
  componentParse: Object.keys(ComponentParse),
  componentMap: Object.keys(ComponentMap)
})

const lastColumn = computed(() => Object.keys(componentsOrder.value).length - 1)

watch(
  preferences,
  () => {
    const layout = preferences.value.layout[KEY_STORAGE]

    if (
      layout &&
      Object.keys(componentsOrder.value).every(
        (key) => layout[key].length === componentsOrder.value[key].length
      )
    ) {
      componentsOrder.value = layout
    }
  },
  { deep: true }
)

function updatePreferences() {
  User.update(preferences.value.id, {
    user: { layout: { [KEY_STORAGE]: componentsOrder.value } }
  }).then(({ body }) => {
    preferences.value.layout = body.preferences
    componentsOrder.value = body.preferences.layout[KEY_STORAGE]
  })
}

User.preferences().then((response) => {
  preferences.value = response.body
})
</script>
