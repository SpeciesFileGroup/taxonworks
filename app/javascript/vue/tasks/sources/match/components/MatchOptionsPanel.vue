<template>
  <div class="match-options-panel panel content">
    <div class="flex-row flex-separate middle margin-medium-bottom">
      <h3>Match options</h3>
      <VBtn
        color="primary"
        title="Reset all options to defaults"
        @click="emit('reset')"
      >
        Reset
      </VBtn>
    </div>

    <div class="flex-col gap-medium">
      <fieldset>
        <legend>Sources</legend>
        <label class="middle">
          <input
            type="radio"
            name="source-scope"
            :checked="!options.limitToProject"
            @change="setScope(false)"
          />
          All Sources
        </label>
        <label class="middle">
          <input
            type="radio"
            name="source-scope"
            :checked="options.limitToProject"
            @change="setScope(true)"
          />
          Only Sources in this project
        </label>
        <label
          v-if="!options.limitToProject"
          class="middle"
          data-help="The same work often exists as several Sources, one per project that added it. When more than one candidate passes but exactly one of them is in this project, match that one."
        >
          <input
            type="checkbox"
            :checked="options.preferProjectSources"
            @change="update('preferProjectSources', $event.target.checked)"
          />
          Prefer Sources in this project
        </label>
      </fieldset>

      <fieldset>
        <legend>Year</legend>
        <div class="horizontal-left-content gap-small middle">
          <span>Allow</span>
          <label
            v-for="tolerance in yearTolerances"
            :key="tolerance"
            class="middle"
          >
            <input
              type="radio"
              name="year-tolerance"
              :checked="options.yearTolerance === tolerance"
              @change="update('yearTolerance', tolerance)"
            />
            {{ tolerance ? `±${tolerance}` : 'exact' }}
          </label>
        </div>
        <label class="middle">
          <input
            type="checkbox"
            :checked="options.matchYearSuffix"
            @change="update('matchYearSuffix', $event.target.checked)"
          />
          Year suffixes (1990a, 1990b) must agree when both present
        </label>
      </fieldset>

      <fieldset>
        <legend>Authors</legend>
        <div
          v-for="option in AUTHOR_SCOPE_OPTIONS"
          :key="option.value"
        >
          <label class="middle">
            <input
              type="radio"
              name="author-scope"
              :checked="options.authorScope === option.value"
              @change="update('authorScope', option.value)"
            />
            {{ option.label }}
          </label>
          <div
            v-if="option.description"
            class="subtle"
          >
            {{ option.description }}
          </div>
        </div>

        <div class="margin-small-top">
          <label class="middle">
            <input
              type="checkbox"
              :checked="options.requireFirstAuthorInitials"
              @change="
                update('requireFirstAuthorInitials', $event.target.checked)
              "
            />
            First author initials must share a letter when both present
          </label>
          <div class="subtle">
            Smit, F.G.A.M. is not Smit, B.; Jordan, K. can be Jordan, Heinrich
            Ernst Karl.
          </div>
        </div>
      </fieldset>

      <fieldset>
        <legend>Surname spelling</legend>
        <div
          v-for="option in AUTHOR_MATCHING_OPTIONS"
          :key="option.value"
        >
          <label class="middle">
            <input
              type="radio"
              name="author-matching"
              :checked="options.authorMatching === option.value"
              @change="update('authorMatching', option.value)"
            />
            {{ option.label }}
          </label>
          <div class="subtle">{{ option.description }}</div>
        </div>

        <div
          v-if="options.authorMatching === AUTHOR_MATCHING.FUZZY"
          class="margin-small-top"
        >
          <label>
            Up to {{ options.authorMaxEdits }}
            {{ pluralize(options.authorMaxEdits, 'edit') }} per surname
          </label>
          <input
            type="range"
            min="1"
            :max="MAX_AUTHOR_EDITS"
            class="full_width"
            :value="options.authorMaxEdits"
            @input="update('authorMaxEdits', Number($event.target.value))"
          />
        </div>
      </fieldset>

      <fieldset>
        <legend
          data-help="How alike the two texts are, 0-100%, by the share of three-letter sequences they have in common (trigram similarity), so small differences in spelling, punctuation, or abbreviation only lower it a little. For a citation pasted as one line: how much of the Source's title (or journal) appears in it. At 0 the field is still compared and shown, but never required."
        >
          Title and journal
        </legend>
        <label>
          Title at least {{ percent(options.minTitleSimilarity) }}
        </label>
        <input
          type="range"
          min="0"
          max="1"
          step="0.05"
          class="full_width"
          :value="options.minTitleSimilarity"
          @input="update('minTitleSimilarity', Number($event.target.value))"
        />
        <label>
          Journal at least {{ percent(options.minJournalSimilarity) }}
        </label>
        <input
          type="range"
          min="0"
          max="1"
          step="0.05"
          class="full_width"
          :value="options.minJournalSimilarity"
          @input="update('minJournalSimilarity', Number($event.target.value))"
        />
      </fieldset>

      <fieldset>
        <legend>Volume and pages</legend>
        <label class="middle">
          <input
            type="checkbox"
            :checked="options.requireVolume"
            @change="update('requireVolume', $event.target.checked)"
          />
          Volume must agree when both present
        </label>
        <label class="middle">
          <input
            type="checkbox"
            :checked="options.requireFirstPage"
            @change="update('requireFirstPage', $event.target.checked)"
          />
          First page must agree when both present
        </label>
      </fieldset>

      <div class="requirements">
        <p>A candidate passes when:</p>
        <ul>
          <li
            v-for="requirement in requirements"
            :key="requirement"
          >
            {{ requirement }}
          </li>
        </ul>
        <p class="subtle">
          A field missing from the row or the Source isn't compared. A DOI
          shared by row and Source always passes; different DOIs never do. A
          row is matched when exactly one candidate passes.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { pluralize } from '@/helpers/strings.js'
import { describeRequirements } from '../utils/evaluate.js'
import {
  AUTHOR_MATCHING,
  AUTHOR_MATCHING_OPTIONS,
  AUTHOR_SCOPE_OPTIONS,
  MAX_AUTHOR_EDITS,
  MAX_YEAR_TOLERANCE
} from '../constants.js'

const emit = defineEmits(['reset', 'refetch'])

const options = defineModel('options', { type: Object, required: true })

const requirements = computed(() => describeRequirements(options.value))

const yearTolerances = Array.from(
  { length: MAX_YEAR_TOLERANCE + 1 },
  (_, i) => i
)

function update(key, value) {
  options.value = { ...options.value, [key]: value }
}

// Changes the candidates themselves, not just how they're judged.
function setScope(limitToProject) {
  update('limitToProject', limitToProject)
  emit('refetch')
}

function percent(value) {
  return value > 0 ? `${Math.round(value * 100)}%` : '(not required)'
}
</script>

<style scoped>
.match-options-panel {
  min-width: 320px;
  max-width: 360px;
}

.requirements ul {
  margin: 4px 0;
  padding-left: 20px;
}

fieldset {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
</style>
