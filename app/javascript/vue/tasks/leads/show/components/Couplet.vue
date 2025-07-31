<template>
  <div class="lead_center">
    <VBtn
      v-if="lead.parent_id"
      color="primary"
      medium
      @click="() => emit('loadLead', lead.parent_id)"
    >
      Up
    </VBtn>

    <div
      v-if="lead.origin_label"
      class="large_type"
    >
      <b>Couplet {{ lead.origin_label }}</b>
    </div>

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
    v-if="couplet.length > 0"
    class="couplet"
  >
    <LeadAndFuture
      v-for="(l, i) in couplet"
      :key="l.id"
      :lead="l"
      :future="futures[i]"
      @load-lead="(id) => emit('loadLead', id)"
    />
  </div>
  <div v-else class="lead_center">
    <p>
      You're viewing a leaf node without the node it's associated with in the
      key; go Up to view the full couplet that includes this lead.
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
  couplet: {
    type: Array,
    default: []
  },
  futures: {
    type: Array,
    default: []
  }
})

const emit = defineEmits(['loadLead'])
</script>

<style lang="scss" scoped>
.couplet {
  margin-top: 2em;
  display: flex;
  flex-wrap: wrap;
  justify-content:space-around;
  gap: 1em;
}
.lead_center {
  display: flex;
  flex-direction: column;
  align-items: center;
  * {
    margin-bottom: .5em;
  }
}
</style>