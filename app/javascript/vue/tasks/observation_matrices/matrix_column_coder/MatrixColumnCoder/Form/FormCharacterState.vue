<template>
  <label class="margin-small-right middle">
    <input
      type="checkbox"
      :checked="checked"
      @change="emit('change', $event)"
    >
    {{ characterState.label }}: {{ characterState.name }}
  </label>
</template>

<script setup>

defineProps({
  characterState: {
    type: Object,
    required: true
  },

  checked: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['change'])

</script>
