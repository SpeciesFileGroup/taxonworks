<template>
  <BlockLayout
    class="previous"
    expand
  >
    <template #header>
      <h3>Previous couplets</h3>
    </template>

    <template #body>
      <div v-if="parents.length">
        <div
          v-for="(o, i) in parents"
          :key="o.id"
          :style="margin_for_depth(i)"
        >
          <a
            :href="RouteNames.ShowLead + 'lead_id=' + o.id"
            @click.prevent = "$emit('loadCouplet', o.id)"
            v-html="lead_tag(o)"
          />
        </div>
      </div>
      <div v-else>
        {{ rootText }} <span v-html="'<i>(At the start)</i>'" />
      </div>
      </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { lead_tag, margin_for_depth } from '../../helpers/formatters.js'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  parents: {
    type: Array,
    required: true
  },
  rootText: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['loadCouplet'])
</script>

<style lang="scss" scoped>
.previous {
  max-width: 600px;
  margin: 2em auto;
}
</style>