<template>
  <FacetContainer>
    <h3>File extensions</h3>
    <div class="extensions">
      <div
        v-for="ext in extensions"
        :key="ext"
      >
        <label @click="() => updateParams(ext)">
          <input
            type="radio"
            :value="ext"
            name="extensions"
          />
          {{ ext }}
        </label>
      </div>
    </div>
  </FacetContainer>
</template>

<script setup>

const props = defineProps({
  extensions: {
    type: Array,
    required: true
  }
})

const params = defineModel()

function updateParams(extension) {
    params.value.file_extension = extension
}
</script>

<style lang="scss" scoped>
.extensions {
  margin-bottom: 1.5em;
}
</style>
