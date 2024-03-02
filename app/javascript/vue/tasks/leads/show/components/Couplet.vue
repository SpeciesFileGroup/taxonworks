<template>
  <div class="cplt_center">
    <VBtn
      v-if="lead.parent_id"
      color="primary"
      medium
      @click="() => emit('loadCouplet', lead.parent_id)"
    >
      Up
    </VBtn>

    <div
      v-if="lead.origin_label"
      class="large_type"
      v-html="'<b>Couplet ' + lead.origin_label + '</b>'"
    />

    <div v-if="lead.otu">
      <a
        :href="lead.otu.object_url"
        target="_blank"
        v-html="lead.otu.object_tag"
      />
    </div>

    <div v-if="lead.link_out && lead.link_out_text">
      <a
        :href="lead.link_out"
        target="_blank"
      >
        {{ lead.link_out_text }}
      </a>
    </div>
  </div>

  <div
    v-if="left_expanded.lead && right_expanded.lead"
    class="left_and_right_cplt"
  >
    <LeadAndFuture
      class="lead_and_future"
      :lead="left_expanded.lead"
      :future="left_expanded.future"
      @load-couplet="(id) => emit('loadCouplet', id)"
    />
    <LeadAndFuture
      class="lead_and_future"
      :lead="right_expanded.lead"
      :future="right_expanded.future"
      @load-couplet="(id) => emit('loadCouplet', id)"
    />
  </div>
  <div v-else class="cplt_center">
    <p>
      You're viewing a leaf node without the node it's associated with in the
      key; go Up to view the full couplet.
    </p>
  </div>
</template>

<script setup>
import LeadAndFuture from './LeadAndFuture.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  lead: {
    type: Object,
    default: {}
  },
  left_expanded: {
    type: Object,
    default: {}
  },
  right_expanded: {
    type: Object,
    default: {}
  }
})

const emit = defineEmits(['loadCouplet'])
</script>

<style lang="scss" scoped>
.left_and_right_cplt {
  margin-top: 2em;
  display: flex;
  justify-content:space-around;
  align-items: flex-start;
  gap: 1em;
}
.lead_and_future {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  // Enough for two full-width medium depictions.
  max-width: calc(600px + 4em + 16px + 4px);
  margin-bottom: 2em;
}
.cplt_center {
  display: flex;
  flex-direction: column;
  align-items: center;
  * {
    margin-bottom: .5em;
  }
}
</style>