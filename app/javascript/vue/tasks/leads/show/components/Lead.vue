<template>
  <div class="lead">
    <div class="navigation">
      <VBtn
        v-if="hasFuture"
        color="primary"
        medium
        @click="$emit('loadCouplet', lead.id)"
      >
        Go
      </VBtn>
    </div>

    <div class="lead_data">
      <div
        v-if="lead.text"
        class="lead_text"
      >
        {{ lead.text }}
      </div>
      <div
        v-else
        v-html="'<i>(No text)</i>'"
      />

      <div v-if="lead.otu">
        <span
          v-if="!lead.otu.taxon_name_id"
          v-html="'Otu: '"
        />
        <a
          :href="lead.otu.object_url"
          target="_blank"
          v-html="lead.otu.object_tag"
        />
      </div>

      <div v-if="displayLinkOut">
        <a :href="'http://' + lead.link_out" target="_blank">
          {{ lead.link_out_text }}
        </a>
      </div>

      <Annotations
        :lead-id="lead.id"
        :show-citations="false"
        medium-depictions
        v-model="hasDepictions"
      />
    </div>

    <div
      class="navigation"
      v-if="hasFuture && hasDepictions"
    >
      <VBtn
        color="primary"
        medium
        @click="$emit('loadCouplet', lead.id)"
      >
        Go
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import Annotations from './Annotations.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  lead: {
    type: Object,
    required: true
  },
  hasFuture: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['loadCouplet'])

const hasDepictions = ref(false)

const displayLinkOut = computed(() => {
  return props.lead.link_out && props.lead.link_out_text
})

</script>

<style lang="scss" scoped>
.lead {
  margin-bottom: 2em;
  padding: 1em 2em;
  transition: all 1s;
  box-shadow: rgba(36, 37, 38, 0.08) 4px 4px 15px 0px;
  border-radius: .9rem;
  background-color: #FFF;
}
.lead_data {
  margin-top: 1em;
  margin-bottom: 1em;
  * {
    margin-bottom: 1em;
  }
}
.lead_text {
  padding: 1em;
  border: 1px solid #eee;
  border-radius: .5em;
  box-shadow: rgba(59, 59, 59, 0.08) 2px 2px 12px 0px;
}
.navigation {
  display: flex;
  justify-content: center;
}
.redirect_notice {
  margin-bottom: 12px;
}
.redirect_select[disabled] {
  opacity: .5;
}
</style>