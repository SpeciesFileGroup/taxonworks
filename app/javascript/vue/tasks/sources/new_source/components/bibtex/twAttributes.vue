<template>
  <div>
    <h3 v-help.section.BibTeX.attributes>TW attributes</h3>
    <div class="field label-above">
      <label>Verbatim contents</label>
      <textarea
        type="text"
        v-model="source.verbatim_contents"
      >
      </textarea>
    </div>
    <div class="field label-above">
      <label>Verbatim keywords</label>
      <textarea
        type="text"
        v-model="source.verbatim_keywords"
        @change="() => (source.isUnsaved = true)"
      >
      </textarea>
    </div>
  </div>
</template>

<script setup>
const source = defineModel({
  type: Object,
  required: true
})
</script>
