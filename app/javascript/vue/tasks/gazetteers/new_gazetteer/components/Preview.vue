<template>
  <!-- TODO? Currently we fetch the preview shape everytime the box is checked,
  whether anything has changed or not -->
  <div class="lmap">
    <label>
      <input
        type="checkbox"
        :disabled="previewDisabled"
        v-model="previewing"
      />
      Preview the union of the shapes you've added the way they will be saved.
      <i>Editing will be turned off during preview.</i>
    </label>
  </div>
</template>

<script setup>

const props = defineProps({
  previewDisabled: {
    type: Boolean,
    default: false
  }
})

const previewing = defineModel()

</script>

<style lang="scss" scoped>
.lmap {
  max-width: 80vw;
  margin: 0px auto 2em auto;
}
</style>
