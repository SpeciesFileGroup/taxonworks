<template>
  <div class="match-lmap">
    <label>
      <input
        type="checkbox"
        :disabled="previewDisabled"
        v-model="previewing"
      />
      {{ message }}
      <i>Editing is turned off during preview.</i>
    </label>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  previewDisabled: {
    type: Boolean,
    default: false
  },
  operationIsUnion: {
    type: Boolean,
    default: true
  }
})

const previewing = defineModel()

const message = computed(() => {
  const operation = props.operationIsUnion ? 'union' : 'intersection'
  return `Preview the ${operation} of the shapes you've added the way they will be saved.`
})

</script>

<style lang="scss" scoped>
// Should be the same as the lmap css
.match-lmap {
  max-width: 80vw;
  margin: 0px auto 2em auto;
}
</style>
