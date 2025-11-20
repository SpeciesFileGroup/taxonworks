<template>
  <div>
    <h3 v-help.section.BibTeX.crosslinks>BibTeX crosslinks</h3>
    <div
      v-for="{ attr, component } in BIBTEX_FIELDS"
      :key="attr"
      class="field label-above"
    >
      <label class="capitalize">{{ attr }}</label>
      <component
        :is="component"
        type="text"
        :value="source[attr]"
        @change="(e) => handleInput(e, attr)"
      />
    </div>
  </div>
</template>

<script setup>
const source = defineModel({
  type: Object,
  required: true
})

const BIBTEX_FIELDS = [
  { attr: 'doi', component: 'input' },
  { attr: 'isbn', component: 'input' },
  { attr: 'issn', component: 'input' },
  { attr: 'note', component: 'textarea' },
  { attr: 'annote', component: 'input' }
]

function handleInput(event, attr) {
  source.value[attr] = event.target.value
  source.value.isUnsaved = true
}
</script>
