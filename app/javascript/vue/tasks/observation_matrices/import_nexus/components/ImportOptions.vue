<template>
  <fieldset class="import_options">
    <legend>Convert</legend>

    <div class="field label-above">
      <label>Matrix name (left blank will provide a timestamped default)</label>
      <input
        type="text"
        class="normal-input full_width"
        v-model="options.matrix_name"
      />
    </div>

    <div>
      <VBtn
        color="update"
        medium
        :disabled="!docChosen"
        @click="emit('convert')"
        class="button"
      >
        Convert
      </VBtn>
    </div>
  </fieldset>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  docChosen: Boolean,
  default: false
})

const emit = defineEmits(['convert'])

const options = defineModel()
options.value = {
  // Default values (don't put in defineModel, where they're not passed to the
  // parent).
  matrix_name: ''
}

</script>

<style lang="scss" scoped>
.import_options {
  width: 600px;
}
.button {
  margin-top: 2em;
  margin-bottom: 1em;
}
</style>