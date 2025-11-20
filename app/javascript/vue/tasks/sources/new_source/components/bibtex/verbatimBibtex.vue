<template>
  <div>
    <h3>Verbatim from BibTeX</h3>
    <div
      v-for="{ attr, label } in VERBATIM_BIBTEX_FIELDS"
      :key="attr"
      class="field"
    >
      <label>{{ label }}</label>
      <input
        type="text"
        v-model="source[attr]"
        @change="() => (source.isUnsaved = true)"
      />
    </div>
  </div>
</template>

<script setup>
const source = defineModel({
  type: Object,
  required: true
})

const VERBATIM_BIBTEX_FIELDS = [
  { attr: 'author', label: 'Author(s)' },
  { attr: 'editor', label: 'Editor(s)' },
  { attr: 'journal', label: 'Journal' }
]
</script>
