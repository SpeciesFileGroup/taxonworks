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
        :disabled="currentLead"
        :title="currentLead ? 'Current couplet' : 'Select couplet'"
        @click.prevent="loadParent"
      >
        <span>
          {{ lead.beginLabel }}
        </span>
      </VBtn>

      <a
        v-if="backLink"
        :href="`#cplt-${backLink}`"
        @click.prevent="() => moveToLead(backLink)"
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

    <DepictionsModal
      v-if="lead.depictions.length"
      :lead="lead"
    />

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
        @click.prevent="() => moveToLead(lead.targetLabel)"
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
          {{ lead.targetLabel }}
        </a>
      </template>

      <ul
        v-if="lead.leadItemOtus.length > 1"
        class="no_bullets"
      >
        <li
          v-for="lio in lead.leadItemOtus"
          :key="lio"
        >
          <a
            :href="makeBrowseUrl({ id: lio.id, type: OTU })"
            target="_blank"
          >
            {{ lio }}
          </a>
        </li>
      </ul>
      <template v-else>
        ...
        <a
          :href="makeBrowseUrl({ id: lead.leadItemOtus[0].id, type: OTU })"
          target="_blank"
        >
          {{ lead.leadItemOtus[0] }}
        </a>
      </template>
    </template>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import useLeadStore from '../../store/lead.js'
import DepictionsModal from '../DepictionsModal.vue'
import { makeBrowseUrl } from '@/helpers/index.js'
import { OTU } from '@/constants'
import { computed } from 'vue'

const props = defineProps({
  lead: Object,
  backLink: {
    type: [Number, String],
    required: false
  }
})

const store = useLeadStore()

const emit = defineEmits(['scroll:couplet'])

const currentLead = computed(() => props.lead.parentId == store.lead.id)

function loadParent() {
  store.loadKey(props.lead.parentId)
}

function moveToLead(couplet) {
  const leadId = store.key_ordered_parents[couplet - 1]

  emit('scroll:couplet', couplet)
  store.loadKey(leadId)
}
</script>

<style scoped>
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
