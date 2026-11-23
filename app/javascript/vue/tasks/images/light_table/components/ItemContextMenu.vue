<template>
  <LightTableMenuItem
    label="Assign OTU..."
    @click="emit('assign-otu')"
  />
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

const emit = defineEmits(['radial', 'assign-otu'])

const meta = computed(() => props.items[0]?.meta)

function objectTypeLabel(object) {
  return object?.base_class
    ? capitalize(decamelize(object.base_class))
    : 'Depicted object'
}

const radialTargets = computed(() => {
  if (!meta.value) return []
  const depictions = meta.value.depictions || []
  const hasMany = depictions.length > 1

  const targets = [
    { label: 'Image', object: meta.value.object },
    ...depictions.flatMap((depiction) => {
      const depicted = depiction.depiction_object
      const suffix = hasMany && depicted ? `: ${depicted.object_label}` : ''

      return [
        { label: `Depiction${suffix}`, object: depiction },
        { label: `${objectTypeLabel(depicted)}${suffix}`, object: depicted }
      ]
    })
  ]

  return targets
    .filter((target) => target.object?.global_id)
    .map((target) => ({
      label: target.label,
      globalId: target.object.global_id
    }))
})
</script>
