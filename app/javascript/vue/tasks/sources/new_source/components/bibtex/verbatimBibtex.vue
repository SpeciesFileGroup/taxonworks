<template>
  <div>
    <h3>Verbatim from BibTeX</h3>
    <div
      v-for="{ attr, label, component, bind } in VERBATIM_BIBTEX_FIELDS"
      :key="attr"
      class="field"
    >
      <label>{{ label }}</label>
      <component
        :is="component"
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
  {
    attr: 'author',
    label: 'Author(s)',
    component: 'textarea'
  },
  { attr: 'editor', label: 'Editor(s)', component: 'input' },
  { attr: 'journal', label: 'Journal', component: 'input' }
]
</script>
