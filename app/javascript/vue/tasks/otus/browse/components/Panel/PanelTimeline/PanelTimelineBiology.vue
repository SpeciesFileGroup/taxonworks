<template>
  <div>
    <ul class="taxonomic_history no_bullets">
      <li
        v-for="citation in citations"
        :key="citation.id"
      >
        <span v-html="citation.source.author_year" /><span v-if="citation.pages"
          >:{{ citation.pages }}</span
        >
      </li>
    </ul>
  </div>
</template>

<script setup>
import { Otu } from '@/routes/endpoints'
import { ref, watch } from 'vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  }
})

const citations = ref([])

watch(
  () => props.otu,
  (otu) => {
    if (!otu) {
      citations.value = []
      return
    }

    Otu.citations(otu.id).then(({ body }) => {
      citations.value = body
    })
  },
  { immediate: true }
)
</script>
