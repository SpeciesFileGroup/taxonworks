<template>
  <div class="new-combination-rank-list">
    <div class="header">
      <h3 class="flex-separate">
        <span class="capitalize">{{ rankName }}</span>
      </h3>
    </div>
    <div class="content">
      <ul class="no_bullets">
        <li
          class="horizontal-left-content gap-small"
          v-for="taxon in sortedList"
          :key="taxon.id"
        >
          <span
            class="new-combination-rank-list-taxon-name"
            v-html="taxon.object_tag"
          />
          <div class="horizontal-left-content gap-small">
            <RadialAnnotator :global-id="taxon.global_id" />
            <VBtn
              circle
              color="primary"
              @click="() => openLink(taxon)"
            >
              <VIcon
                name="pencil"
                x-small
              />
            </VBtn>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { computed } from 'vue'
import { COMBINATION } from '@/constants'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  list: {
    type: Array,
    required: true
  },
  rankName: {
    type: String,
    required: true
  }
})

const sortedList = computed(() =>
  props.list.toSorted((a, b) => {
    if (a.original_combination < b.original_combination) {
      return -1
    }
    if (a.original_combination > b.original_combination) {
      return 1
    }
    return 0
  })
)

function openLink(taxon) {
  const link =
    taxon.type === COMBINATION
      ? `${RouteNames.NewCombination}?combination_id=${taxon.id}`
      : `${RouteNames.NewTaxonName}?taxon_name_id=${taxon.id}`

  window.open(link, '_blank')
}
</script>
<style lang="scss">
.new-combination-rank-list {
  transition: all 0.5 ease;
  display: flex;
  flex-direction: column;
  .header {
    padding: 1em;
    border-bottom: 1px solid #f5f5f5;
    h3 {
      font-weight: 300;
    }
  }
}
</style>
