<template>
  <BlockLayout
    expand
    :set-expanded="false"
    class="lead_header"
  >
    <template #header>
      <div class="flex-separate middle full_width">
        <h3>
          <a
            v-if="root.link_out"
            :href="root.link_out"
            target="_blank"
          >
            {{ root.text }}
          </a>
          <template v-else>
            {{ root.text }}
          </template>
        </h3>
        <div class="horizontal-right-content gap-small header-radials">
          <RadialNavigator :global-id="root.global_id" />
        </div>
      </div>
    </template>
    <template #body>
      <div
        v-if="root.description"
        class="root-data"
      >
        {{ root.description }}
      </div>

      <div
        v-if="root.otu"
        class="root-data"
      >
        <template v-if="!root.otu.taxon_name_id">
          Otu:
        </template>
        <a
          :href="root.otu.object_url"
          target="_blank"
          v-html="root.otu.object_tag"
        />
      </div>

      <Annotations :lead-id="root.id" />
    </template>
  </BlockLayout>
</template>

<script setup>
import Annotations from './Annotations.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

const props = defineProps({
  root: {
    type: Object,
    required: true
  }
})
</script>

<style lang="scss" scoped>
.lead_header {
  margin: 1em auto;
  max-width: 1240px;
}
.header-radials {
  margin-right: .5em;
}
.root-data {
  margin-bottom: 1em;
}
</style>
