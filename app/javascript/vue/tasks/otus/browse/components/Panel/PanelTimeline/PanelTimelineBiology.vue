<template>
  <div class="">
    <VSkeleton
      v-if="isLoading"
      {
      variant="text"
      :lines="6"
      }
    />
    <template v-else>
      <div class="text-base font-bold">Citations ({{ list.length }})</div>
      <div class="margin-medium-top margin-xlarge-bottom">
        <ul class="taxonomic_history no_bullets">
          <li
            v-for="item in list"
            :key="item.id"
            class="margin-small-bottom"
          >
            <a
              v-html="item.otu.label"
              :href="`${RouteNames.BrowseOtu}?otu_id=${item.otu.id}`"
            />
            in
            <a
              :href="`${RouteNames.NomenclatureBySource}?source_id=${item.source.id}`"
              v-html="item.label"
            />
            <VBadge
              class="d-inline margin-xsmall-left margin-xsmall-right"
              color="purple"
              rounded
              >{{ item.type }}</VBadge
            >
            <div
              class="pill topic d-inline"
              :style="{
                backgroundColor: topic.css_color
              }"
              v-for="topic in item.topics"
            >
              {{ topic.name }}
            </div>
          </li>
        </ul>
      </div>
      <template v-if="references.length">
        <div class="text-base font-bold margin-small-bottom">References</div>
        <table class="no_bullets table-striped">
          <thead>
            <tr>
              <th class="w-2"></th>
              <th class="w-2"></th>
              <th>Source</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="source in references"
              :key="source.id"
            >
              <td>
                <input
                  v-model="selectedSources"
                  :value="source.id"
                  class="margin-small-right"
                  type="checkbox"
                />
              </td>
              <td>
                <div class="flex-row gap-small">
                  <RadialAnnotator :global-id="source.global_id" />
                  <RadialNavigator :global-id="source.global_id" />
                </div>
              </td>
              <td>
                <span v-html="source.cached" />
              </td>
            </tr>
          </tbody>
        </table>
      </template>
    </template>
  </div>
</template>

<script setup>
import { Otu } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'
import { RouteNames } from '@/routes/routes'
import VSkeleton from '@/components/ui/VSkeleton/VSkeleton.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import { getUnique } from '@/helpers'

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
const isLoading = ref(false)
const selectedSources = ref([])

const otuIds = computed(() => props.otus.map((o) => o.id))

const references = computed(() =>
  getUnique(
    citations.value
      .map((item) => item.citations)
      .flat()
      .map((c) => c.source),
    'id'
  )
)

const list = computed(() => {
  const otus = citations.value.filter((item) =>
    otuIds.value.includes(item.otu.id)
  )
  const items = otus.map((o) => {
    return o.citations
      .filter(
        (c) =>
          !selectedSources.value.length ||
          selectedSources.value.includes(c.source.id)
      )
      .map((c) => {
        const citation = [c.source.author_year, c.pages]
          .filter(Boolean)
          .join(':')

        return {
          id: c.id,
          type: c.citation_object_type,
          label: citation,
          otu: o.otu,
          source: c.source,
          topics: c.topics
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

    isLoading.value = true

    Otu.citations(otu.id)
      .then(({ body }) => {
        citations.value = body
      })
      .finally(() => {
        isLoading.value = false
      })
  },
  { immediate: true }
)
</script>

<style scoped>
td {
  padding: var(--spacing-xs) var(--spacing-xs);
}

td:first-child {
  padding-right: 0;
}
</style>
