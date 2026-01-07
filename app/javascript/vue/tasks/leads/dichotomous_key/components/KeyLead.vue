<template>
  <div
    :class="{
      'key-lead-selected': lead.isFirstLine && lead.parentId == store.lead.id
    }"
  >
    <span v-if="lead.isFirstLine">
      <VBtn
        :id="`cplt-${lead.beginLabel}`"
        class="couplet"
        color="primary"
        @click.prevent="loadParent"
      >
        <span>
          {{ lead.beginLabel }}
        </span>
      </VBtn>

      <a
        v-if="backLink"
        :href="`#cplt-${backLink}`"
        @click.prevent="() => emit('scroll:couplet', backLink)"
      >
        ({{ backLink }})
      </a>
    </span>

    <span
      v-else
      class="dash"
      >{{ lead.beginLabel }}</span
    >

    {{ lead.text }}

    <span
      v-if="lead.hasMultipleOtus"
      class="lead-item-mark"
      >!!</span
    >
    <span
      v-else-if="lead.hasSingleOtuWithoutTarget"
      class="lead-item-one"
      >!!</span
    >

    <template v-if="lead.linkType === 'otu'">
      ...
      <a
        :href="makeBrowseUrl({ id: lead.targetId, type: OTU })"
        target="_blank"
      >
        {{ lead.targetLabel }}
      </a>
    </template>

    <template v-else-if="lead.linkType === 'couplet'">
      ...
      <a
        :href="`#cplt-${lead.targetLabel}`"
        @click.prevent="() => emit('scroll:couplet', lead.targetLabel)"
      >
        {{ lead.targetLabel }}
      </a>
    </template>

    <template v-else-if="lead.linkType === 'lead_item_otus'">
      <template v-if="lead.targetId">
        ...&nbsp;
        <a
          :href="makeBrowseUrl({ id: lead.targetId, type: OTU })"
          target="_blank"
        >
          {{ store.key_data[child]['target_label'] }}
        </a>
      </template>

      <ul class="key-ul">
        <li
          v-for="lio in lead.leadItemOtus"
          :key="lio"
        >
          {{ lio }}
        </li>
      </ul>
    </template>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import useLeadStore from '../store/lead.js'
import { makeBrowseUrl } from '@/helpers/index.js'
import { OTU } from '@/constants'

const props = defineProps({
  lead: Object,
  backLink: {
    type: [Number, String],
    required: false
  }
})

const store = useLeadStore()

const emit = defineEmits(['scroll:couplet'])

function loadParent() {
  store.loadKey(props.lead.parentId)
}
</script>

<style scoped>
.key-lead-selected {
  font-weight: bold;
}

.key-lead-selected::before {
  display: inline-block;
  margin-left: -2rem;
  padding-right: 0.5rem;
  content: '>>>';
  width: 1.5rem;
}

.couplet {
  scroll-margin-top: 0px;
}
</style>
