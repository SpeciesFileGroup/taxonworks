<template>
  <div class="flex-row flex-separate middle gap-medium">
    <div class="flex-row gap-small middle">
      <div
        :class="['inline model-tag', modelBg]"
        v-if="objectType"
      >
        {{ objectType }}
      </div>
      <span v-html="title" />
    </div>
    <CopyObjectId
      v-if="objectId"
      :object-id="objectId"
      :object-type="objectType"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import CopyObjectId from './CopyObjectId.vue'
import {
  PERSON,
  PREPARATION_TYPE,
  REPOSITORY,
  SERIAL,
  ORGANIZATION,
  SOURCE,
  GEOGRAPHIC_AREA,
  NAMESPACE
} from '@/constants/modelTypes.js'

const DATA_COLOR = {
  shared: [
    PERSON,
    NAMESPACE,
    REPOSITORY,
    PREPARATION_TYPE,
    SERIAL,
    SOURCE,
    ORGANIZATION
  ],
  application: [GEOGRAPHIC_AREA]
}

const props = defineProps({
  objectType: {
    type: String,
    default: undefined
  },

  objectId: {
    type: [String, Number],
    default: undefined
  },

  title: {
    type: String,
    default: ''
  }
})

const modelBg = computed(() => {
  const objectType = props.objectType

  if (!objectType) return

  const type = Object.keys(DATA_COLOR).find((key) => {
    return DATA_COLOR[key].includes(objectType)
  })

  return type || ''
})
</script>

<style lang="scss" scoped>
.model-tag {
  padding: 5px 8px;
  border-top-right-radius: 0.6rem;
  border-bottom-right-radius: 0.6rem;
  border: 1px solid var(--color-primary);
  border-left: 12px solid var(--color-primary);
  line-height: 1.2rem;
}

.shared {
  border: 1px solid var(--data-shared-bg);
  border-left: 12px solid var(--data-shared-bg);
}

.application {
  border: 1px solid var(--data-application-defined-bg);
  border-left: 12px solid var(--data-application-defined-bg);
}
</style>
