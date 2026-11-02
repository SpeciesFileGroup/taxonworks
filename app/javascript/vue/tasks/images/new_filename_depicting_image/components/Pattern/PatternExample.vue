<template>
  <div
    v-if="store.isPatternValid"
    class="flex-col gap-small"
  >
    <span>{{ examples.length > 1 ? 'Examples' : 'Example' }}</span>
    <div
      v-for="(example, index) in examples"
      :key="index"
      class="flex-col gap-xsmall"
    >
      <div class="horizontal-left-content middle gap-xsmall pattern-example">
        <template
          v-for="segment in example.segments"
          :key="segment.id"
        >
          <VBadge
            v-if="segment.role"
            :color="ROLE_COLORS[segment.role]"
            :title="ROLE_LABELS[segment.role]"
          >
            {{ segment.text }}
          </VBadge>
          <span v-else>{{ displaySeparator(segment.text) }}</span>
        </template>
        <span>.jpg</span>
      </div>
      <ul class="margin-remove">
        <li>
          Identifier: <b>{{ example.identifier }}</b>
        </li>
        <li v-if="example.figureLabel">
          Figure label: <b>{{ example.figureLabel }}</b>
        </li>
        <li v-if="example.caption">
          Caption: <b>{{ example.caption }}</b>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../../store/store'
import { ROLE_COLORS, ROLE_LABELS } from '../../constants'
import {
  buildExample,
  displaySeparator,
  optionalGroups
} from '../../utils/pattern'
import VBadge from '@/components/ui/VBadge/VBadge.vue'

const store = useStore()

const examples = computed(() => {
  const hasOptional = optionalGroups(store.composition).groups.length > 0
  const full = buildExample(store.composition)

  return hasOptional
    ? [full, buildExample(store.composition, { withOptional: false })]
    : [full]
})
</script>

<style scoped>
.pattern-example {
  flex-wrap: wrap;
  white-space: pre;
}

.pattern-example :deep(.v-badge) {
  width: auto;
}
</style>
