<template>
  <div class="lead">
    <div class="navigation">
      <VBtn
        v-if="hasFuture"
        color="primary"
        medium
        @click="() => emit('loadLead', goId)"
      >
        {{ goText }}
      </VBtn>
    </div>

    <div class="lead_data">
      <div
        v-if="lead.text"
        class="lead_text data_item"
      >
        {{ lead.text }}
      </div>
      <div
        v-else
        class="data_item"
      >
        <i>(No text)</i>
      </div>

      <div
        v-if="displayLinkOut"
        class="lead_determination data_item"
      >
        <a
          :href="lead.link_out"
          target="_blank"
        >
          {{ lead.link_out_text }}
        </a>
      </div>

      <div
        v-if="lead.otu"
        class="lead_determination data_item"
      >
        <a
          :href="lead.otu.object_url"
          target="_blank"
          v-html="lead.otu.object_tag"
        />
      </div>

      <Annotations
        :lead-id="lead.id"
        :show-citations="false"
        medium-depictions
        v-model="hasDepictions"
        class="data_item"
      />
    </div>

    <div
      class="navigation"
      v-if="hasFuture && hasDepictions"
    >
      <VBtn
        color="primary"
        medium
        @click="() => emit('loadLead', goId)"
      >
        {{ goText }}
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

const emit = defineEmits(['loadLead'])

const hasDepictions = ref(false)

const goId = computed(() => {
  return props.lead.redirect_id || props.lead.id
})

const goText = computed(() => {
  return props.lead.redirect_id ? 'Go - follow redirect' : 'Go'
})

const displayLinkOut = computed(() => {
  return props.lead.link_out && props.lead.link_out_text
})
</script>

<style lang="scss" scoped>
.lead {
  padding: 1em 2em;
  box-shadow: var(--panel-shadow);
  border-radius: 0.9rem;
  background-color: var(--bg-foreground);
}
.lead_data {
  margin-top: 1em;
  margin-bottom: 1em;
}
.data_item {
  margin-bottom: 1em;
}
.lead_text {
  padding: 1em;
  border: 1px solid var(--border-color);
  border-radius: 0.5em;
  box-shadow: var(--panel-shadow);
}
.navigation {
  display: flex;
  justify-content: center;
}
.redirect_notice {
  margin-bottom: 0.5em;
}
.redirect_select[disabled] {
  opacity: 0.5;
}
.lead_determination {
  text-align: end;
}
</style>
