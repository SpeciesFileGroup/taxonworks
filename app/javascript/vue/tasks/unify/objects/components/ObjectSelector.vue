<template>
  <div>
    <div class="flex-separate middle">
      <b>{{ title }}</b>
      <div
        class="horizontal-left-content gap-small"
        v-if="selected"
      >
        <RadialAnnotator :global-id="selected.global_id" />
        <RadialObject
          v-if="TYPE_LINKS[model].radialObject"
          :global-id="selected.global_id"
        />
        <RadialNavigator :global-id="selected.global_id" />
        <VBtn
          circle
          color="primary"
          @click="() => (selected = null)"
        >
          <VIcon
            name="trash"
            x-small
          />
        </VBtn>
      </div>
    </div>
    <div v-show="!selected">
      <SmartSelector
        v-if="modelOpts.smartSelector"
        :model="modelOpts.smartSelector"
        :target="modelOpts.target"
        :filter-ids="excludeIds"
        :label="modelOpts.smartSelectorLabel || 'object_tag'"
        v-model="selected"
      />
      <VAutocomplete
        v-else
        :url="modelOpts.autocomplete"
        :min="2"
        param="term"
        placeholder="Select an object"
        label="label_html"
        :excluded-ids="excludeIds"
        clear-after
        @select="({ id }) => loadObjectById(id)"
      />
    </div>
    <span
      v-if="selected"
      v-html="selected.object_tag"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { TYPE_LINKS } from '../constants/types'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import * as endpoints from '@/routes/endpoints'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  title: {
    type: String,
    required: true
  },

  model: {
    type: String,
    required: true
  },

  excludeIds: {
    type: Array,
    default: () => []
  }
})

const selected = defineModel({
  type: [Object, null],
  default: undefined
})

const modelOpts = computed(() => TYPE_LINKS[props.model])

function loadObjectById(id) {
  endpoints[props.model].find(id).then(({ body }) => {
    selected.value = body
  })
}

defineExpose({
  loadObjectById
})
</script>
