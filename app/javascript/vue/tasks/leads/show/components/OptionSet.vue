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
      <b>Option set {{ lead.origin_label }}</b>
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
    v-if="optionSet.length > 0"
    class="option_set"
  >
    <LeadAndFuture
      v-for="(l, i) in optionSet"
      :key="l.id"
      class="lead_and_future"
      :lead="l"
      :future="futures[i]"
      @load-lead="(id) => emit('loadLead', id)"
    />
  </div>
  <div v-else class="lead_center">
    <p>
      You're viewing a leaf node without the node it's associated with in the
      key; go Up to view the full option set that includes this lead.
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
  optionSet: {
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
.option_set {
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
.lead_center {
  display: flex;
  flex-direction: column;
  align-items: center;
  * {
    margin-bottom: .5em;
  }
}
</style>