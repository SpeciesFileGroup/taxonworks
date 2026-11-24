<template>
  <div
    v-for="{ candidate, i } in listed"
    :key="candidate.source.id"
    :class="[
      'candidate',
      { 'candidate-failing': !evaluation.evaluations[i].passes }
    ]"
  >
    <input
      type="radio"
      :name="`candidate-${row.index}`"
      :checked="exportedSourceId === candidate.source.id"
      title="Select this Source for the row"
      @click="emit('select-candidate', { index: row.index, candidate })"
    />
    <a
      :href="sourceUrl(candidate.source.id)"
      target="_blank"
      v-html="candidate.source.object_label"
    />
    <div class="candidate-checks">
      <VBadge
        v-if="isAutomaticPick(evaluation, candidate)"
        class="line-nowrap"
        :color="STATUS_BADGE_COLORS[evaluation.status]"
        :title="
          evaluation.status === STATUS.MATCHED
            ? 'The automatic match; select it to keep it whatever the options'
            : 'The best of the candidates that pass; select one to resolve the row'
        "
      >
        {{ evaluation.status === STATUS.MATCHED ? 'Match' : 'Best guess' }}
      </VBadge>
      <VBadge
        v-if="!candidate.in_project"
        class="line-nowrap"
        color="purple"
      >
        Not in project
      </VBadge>
      <CheckChips :evaluation="evaluation.evaluations[i]" />
    </div>
  </div>
  <label class="candidate">
    <input
      type="radio"
      :name="`candidate-${row.index}`"
      :checked="row.noMatch"
      title="None of these Sources is the row's"
      @click="emit('select-none', { index: row.index })"
    />
    <span>None of these</span>
  </label>
  <VBtn
    v-if="hiddenCount"
    class="margin-xsmall-top"
    color="primary"
    medium
    @click="showAll = !showAll"
  >
    {{ hiddenToggleLabel }}
  </VBtn>
</template>

<script setup>
import { computed, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import { pluralize } from '@/helpers/strings.js'
import CheckChips from './CheckChips.vue'
import {
  anyPasses,
  isAutomaticPick,
  listedCandidates,
  unlistedCount
} from '../utils/listing.js'
import { STATUS, STATUS_BADGE_COLORS } from '../constants.js'

// Whether the unlisted candidates are shown too.
const showAll = ref(false)

const props = defineProps({
  // a result row: { index, candidates, noMatch, ... }
  row: {
    type: Object,
    required: true
  },

  // the row's evaluateRow() result
  evaluation: {
    type: Object,
    required: true
  },

  // the id the row exports (matched or selected), else null
  exportedSourceId: {
    type: Number,
    default: null
  }
})

const emit = defineEmits(['select-candidate', 'select-none'])

const listed = computed(() =>
  listedCandidates(props.row, props.evaluation, showAll.value)
)

const hiddenCount = computed(() => unlistedCount(props.row, props.evaluation))

const hiddenToggleLabel = computed(() => {
  const passing = anyPasses(props.evaluation)
  if (showAll.value) {
    return passing
      ? 'Hide those that fail a requirement'
      : 'Hide those where nothing but the authors agrees'
  }
  const count = hiddenCount.value
  return passing
    ? `Show ${count} that ${pluralize(count, 'fails', 'fail')} a requirement`
    : `Show ${count} where nothing but the authors agrees`
})

function sourceUrl(id) {
  return `/sources/${id}`
}
</script>

<style scoped>
.candidate {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr) 320px;
  align-items: center;
  gap: 8px;
  padding: 2px 0;
}

.candidate-checks {
  display: flex;
  align-items: center;
  gap: 4px;
}

.candidate-failing,
.candidate-failing a {
  color: var(--text-muted-color);
}
</style>
