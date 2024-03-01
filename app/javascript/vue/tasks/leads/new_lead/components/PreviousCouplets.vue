<template>
  <BlockLayout
    class="new-lead-previous"
    expand
  >
    <template #header>
      <h3>Previous couplets</h3>
    </template>

    <template #body>
      <div v-if="store.parents.length">
        <template
          v-for="(o, i) in selfAndParents"
          :key="o.id"
        >
          <div
            v-if="i > 0"
            :style="marginForDepth(i - 1)"
            class="new-lead-half-couplet"
          >
            <a
              :href="RouteNames.NewLead + '?lead_id=' + (o.parent_id)"
              @click.prevent="store.loadKey(o.parent_id)"
              v-html="textForParents(selfAndParents, i)"
            />
          </div>
        </template>
      </div>
      <div v-else>
        <i>(At the start)</i>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed } from 'vue'
import { leadText, marginForDepth } from '../../helpers/formatters.js'
import { RouteNames } from '@/routes/routes'
import { useStore } from '../store/useStore.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const store = useStore()

const selfAndParents = computed(() => {
  return [...store.parents, store.lead]
})

function textForParents(parents, i) {
  const optionChosenText = leadText(parents[i])
  const coupletLabelOfChosenOption = parents[i-1].origin_label
  if (coupletLabelOfChosenOption) {
    return (
      '<span class="lead-super">[' + coupletLabelOfChosenOption + ']</span> '
      + optionChosenText
    )
  }
  return optionChosenText
}
</script>

<!-- Not scoped so we can use it in v-html -->
<style lang="scss">
.new-lead-previous {
  max-width: 600px;
  margin: 2em auto;
}
.new-lead-half-couplet {
  margin-bottom: .5em;
}
.lead-super {
  vertical-align: super;
}
</style>