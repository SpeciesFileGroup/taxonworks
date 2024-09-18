<template>
  <div class="field">
    <label>Parent</label>
    <VAutocomplete
      v-if="!parentId"
      url="/containers/autocomplete"
      placeholder="Search a container..."
      param="term"
      label="label"
      @get-item="(container) => (parentId = container.id)"
    />
    <div
      v-if="parent"
      class="horizontal-left-content gap-small middle"
    >
      <input
        class="full_width"
        type="text"
        disabled="true"
        :value="parent.object_label"
      />
      <VBtn
        color="primary"
        circle
        @click="() => (parentId = null)"
      >
        <VIcon
          name="trash"
          x-small
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Container } from '@/routes/endpoints'
import { CONTAINER_PARAMETERS } from '../constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  types: {
    type: Array,
    default: () => []
  }
})

const parentId = defineModel({
  type: [Number, null],
  required: true
})

const parent = ref()

watch(parentId, (newVal) => {
  if (newVal) {
    Container.find(newVal, CONTAINER_PARAMETERS).then(({ body }) => {
      parent.value = body
    })
  } else {
    parent.value = undefined
  }
})
</script>
