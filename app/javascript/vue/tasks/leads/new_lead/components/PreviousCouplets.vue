<template>
  <BlockLayout
    class="previous"
    expand
  >
    <template #header>
      <h3>Previous couplets</h3>
    </template>

    <template #body>
      <div v-if="store.parents.length">
        <div
          v-for="(o, i) in store.parents"
          :key="o.id"
          :style="margin_for_depth(i)"
        >
          <a
            :href="RouteNames.NewLead + '?id=' + o.id"
            @click.prevent="store.loadKey(o.id)"
            v-html="lead_tag(o)"
          />
        </div>
      </div>
      <div v-else>
        <i>(At the start)</i>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { lead_tag, margin_for_depth } from '../../helpers/formatters.js'
import { RouteNames } from '@/routes/routes'
import { useStore } from '../store/useStore.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const store = useStore()
</script>

<style lang="scss" scoped>
.previous {
  max-width: 600px;
  margin: 2em auto;
}
</style>