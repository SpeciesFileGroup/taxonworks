<template>
  <FacetContainer>
    <h3>File extensions</h3>
    <div class="extensions">
      <div
        v-for="ext in [ANY_EXTENSION].concat(extensions)"
        :key="ext"
      >
        <label @click="() => updateParams(ext)">
          <input
            type="radio"
            :value="ext"
            :checked="ext == ANY_EXTENSION"
            name="extensions"
          />
          {{ ext }}
        </label>
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>
const ANY_EXTENSION = 'Any extension'

const props = defineProps({
  extensions: {
    type: Array,
    required: true
  }
})

const params = defineModel()

function updateParams(extension) {
  if (extension == ANY_EXTENSION) {
    params.value.file_extension = ''
  } else {
    params.value.file_extension = extension
  }
}
</script>

<style lang="scss" scoped>
.extensions {
  margin-bottom: 1.5em;
}
</style>
