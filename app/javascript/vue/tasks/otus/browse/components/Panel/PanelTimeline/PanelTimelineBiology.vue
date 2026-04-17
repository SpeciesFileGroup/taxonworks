<template>
  <div>
    <div class="text-base font-bold">Citations ({{ list.length }})</div>
    <div class="margin-medium-top margin-medium-bottom">
      <ul class="taxonomic_history no_bullets">
        <li
          v-for="citation in list"
          :key="citation.id"
          class="margin-small-bottom"
        >
          <span v-html="citation.label" />
        </li>
      </ul>
    </div>
    <div class="text-base font-bold">References</div>
    <div class="margin-medium-top margin-medium-bottom">
      <ul class="taxonomic_history no_bullets">
        <li
          v-for="citation in list"
          :key="citation.id"
          class="margin-small-bottom"
        >
          <span v-html="citation.source" />
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { Otu } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  }
})

const citations = ref([])

const list = computed(() => {
  const items = props.otus.map((o) => {
    const arr = citations.value?.[o.id] || []

    return arr.map((c) => {
      const citation = [c.source.author_year, c.pages].filter(Boolean).join(':')

      return {
        id: c.id,
        label: `${o.object_tag} in <a href="${RouteNames.NomenclatureBySource}?source_id=${c.source.id}">${citation}</a>`,
        source: c.source.cached
      }
    })
  })

  return items.flat()
})

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
