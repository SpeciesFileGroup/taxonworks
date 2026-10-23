<template>
  <VModal
    :container-style="{ width: '600px', maxWidth: '90vw' }"
    @close="emit('close')"
  >
    <template #header>
      <h3>Assign OTU to {{ items.length }} image(s)</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <div class="flex-col gap-small">
        <OtuAutoselectPicker
          v-if="!otu"
          preferences-key="otu_for_light_table"
          autofocus
          @get-item="selectOtu"
        />
        <SmartSelectorItem
          v-else
          :item="otu"
          label="object_tag"
          @unset="clear"
        />

        <template v-if="plan">
          <p v-if="!summary.length">Nothing to assign.</p>
          <ul v-else>
            <li
              v-for="line in summary"
              :key="line"
            >
              {{ line }}
            </li>
          </ul>
        </template>
      </div>
    </template>
    <template #footer>
      <div class="horizontal-right-content gap-small">
        <VBtn
          color="primary"
          variant="outline"
          medium
          @click="emit('close')"
        >
          Cancel
        </VBtn>
        <VBtn
          color="create"
          medium
          :disabled="!changeCount || isLoading"
          @click="applyOtu"
        >
          Assign
        </VBtn>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import { SKIP_REASONS } from '../adapters/applyOtu'
import { useApplyOtu } from '../composables/useApplyOtu'
import VModal from '@/components/ui/Modal.vue'
import OtuAutoselectPicker from '@/components/otu/otu_picker/otu_autoselect_picker.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const SKIP_MESSAGES = {
  [SKIP_REASONS.alreadyOnOtu]: (n) =>
    `${n} already on this OTU, nothing will be done`,
  [SKIP_REASONS.anatomicalPartOnOtu]: (n) =>
    `${n} anatomical part(s) originate from an OTU, not supported yet`,
  [SKIP_REASONS.unsupported]: (n) =>
    `${n} depiction(s) of other objects, not supported`
}

const props = defineProps({
  items: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['close', 'applied'])

const { plan, isLoading, preview, apply } = useApplyOtu()
const otu = ref(null)

const changeCount = computed(() =>
  plan.value
    ? plan.value.moves.length +
      plan.value.creates.length +
      plan.value.determinations.length
    : 0
)

const skippedByReason = computed(() => {
  const counts = {}

  plan.value?.skipped.forEach(({ reason }) => {
    counts[reason] = (counts[reason] || 0) + 1
  })

  return counts
})

const summary = computed(() => {
  if (!plan.value) return []
  const { moves, creates, determinations } = plan.value

  return [
    moves.length && `${moves.length} depiction(s) will be moved to this OTU`,
    creates.length &&
      `${creates.length} image(s) will get a new depiction of this OTU`,
    determinations.length &&
      `${determinations.length} collection object(s) / field occurrence(s) will get a new determination`,
    ...Object.entries(skippedByReason.value).map(([reason, n]) =>
      SKIP_MESSAGES[reason](n)
    )
  ].filter(Boolean)
})

function selectOtu(item) {
  otu.value = item
  preview(props.items, item.id).catch(() => {})
}

function clear() {
  otu.value = null
  plan.value = null
}

async function applyOtu() {
  const { applied, failed } = await apply(otu.value.id)
  const alreadyOnOtu = skippedByReason.value[SKIP_REASONS.alreadyOnOtu]

  const message = [
    failed
      ? `${applied} change(s) applied, ${failed} failed.`
      : `${applied} change(s) applied.`,
    alreadyOnOtu && `${alreadyOnOtu} already on this OTU, nothing was done.`
  ]
    .filter(Boolean)
    .join(' ')

  TW.workbench.alert.create(message, failed ? 'error' : 'notice')

  emit('applied', {
    hasDeterminations: plan.value.determinations.length > 0
  })
}
</script>
