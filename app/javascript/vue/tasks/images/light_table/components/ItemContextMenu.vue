<template>
  <template v-if="items.length === 1 && radialTargets.length">
    <LightTableSubmenu
      v-for="radial in RADIALS"
      :key="radial.type"
      :label="radial.label"
    >
      <LightTableMenuItem
        v-for="target in radialTargets"
        :key="target.globalId"
        :label="target.label"
        @click="emit('radial', { type: radial.type, globalId: target.globalId })"
      />
    </LightTableSubmenu>
  </template>
</template>

<script setup>
import { computed } from 'vue'
import { LightTableMenuItem, LightTableSubmenu } from '@/components/LightTable'
import { DEPICTION } from '@/constants'
import { capitalize, decamelize } from '@/helpers'

const RADIALS = [
  { type: 'annotator', label: 'Annotations' },
  { type: 'navigator', label: 'Navigation' }
]

const props = defineProps({
  items: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['radial'])

const meta = computed(() => props.items[0]?.meta)
const isDepiction = computed(() => meta.value?.objectType === DEPICTION)

const radialTargets = computed(() => {
  if (!meta.value) return []
  const { object } = meta.value

  const targets = isDepiction.value
    ? [
        { label: 'Image', object: object.image },
        { label: 'Depiction', object },
        {
          label: object.depiction_object?.base_class
            ? capitalize(decamelize(object.depiction_object.base_class))
            : 'Depicted object',
          object: object.depiction_object
        }
      ]
    : [{ label: 'Image', object }]

  return targets
    .filter((target) => target.object?.global_id)
    .map((target) => ({
      label: target.label,
      globalId: target.object.global_id
    }))
})
</script>
