<template>
  <div class="helper">
    <div
      v-for="ext in EXTENSIONS"
      :key="ext['ext']"
    >
      <span :class="classForExt[ext['ext']]">&#x25CF;</span> {{ ext['text'] }}
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const EXTENSIONS = [
  { ext: '.shp', text: '.shp', required: true },
  { ext: '.shx', text: '.shx', required: true },
  { ext: '.dbf', text: '.dbf', required: true },
  { ext: '.prj', text: '.prj', required: true },
  {
    ext: '.cpg',
    text: '.cpg (optional, but upload it if you have it)',
    required: false
  }
]

const props = defineProps({
  docs: {
    type: Array,
    default: []
  }
})

const classForExt = ref({})

watch(() => props.docs.length,
  () => {
    loadClassForExt()
  },
  { immediate: true }
)

function loadClassForExt() {
  EXTENSIONS.forEach((ext) => {
    if (props.docs.some(
      (doc) => { return doc.document_file_file_name.endsWith(ext['ext']) })
    ) {
      classForExt.value[ext['ext']] = 'added'
    } else {
      classForExt.value[ext['ext']] = ext['required'] ? 'missing' : 'optional'
    }
  })
}

</script>

<style lang="scss" scoped>
  .helper {
    margin-left: 1em;
    margin-bottom: 1em;
  }

  .missing {
    color: var(--error);
  }

  .added {
    color: var(--create);
  }

  .optional {
    color: var(--attention);
  }
</style>