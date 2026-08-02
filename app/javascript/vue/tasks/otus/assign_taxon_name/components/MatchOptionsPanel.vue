<template>
  <div class="match-options-panel panel content">
    <div class="flex-row flex-separate middle margin-medium-bottom">
      <h3>Match options</h3>
      <VBtn
        color="primary"
        title="Reset all options and re-run matching"
        @click="handleReset"
      >
        Reset
      </VBtn>
    </div>

    <div class="flex-col gap-medium">
      <!-- Scope to TaxonName -->
      <div
        v-if="taxonNameFilterUrl"
        class="field margin-medium-bottom"
      >
        <label>Matched against</label>
        <span class="subtle">
          A taxon name filter result.
          <a :href="taxonNameFilterUrl">Back to filter</a>
        </span>
      </div>

      <div
        v-else
        class="field margin-medium-bottom"
      >
        <label>Restrict matches to children of</label>

        <Autocomplete
          url="/taxon_names/autocomplete"
          param="term"
          label="label_html"
          :clear-after="true"
          placeholder="Search taxon name to scope..."
          @getItem="handleScopeSelect"
        />

        <div
          v-if="scopeTaxonName"
          class="margin-small-top horizontal-left-content gap-small"
        >
          <span class="subtle">
            Scoped to: <span v-html="scopeTaxonName.label" />
          </span>
          <VBtn
            circle
            color="primary"
            title="Clear scope"
            @click="clearScope"
          >
            <VIcon
              xx-small
              name="close"
            />
          </VBtn>
        </div>
      </div>

      <!-- Strip presets -->
      <div class="field margin-medium-bottom">
        <label
          data-help="Applied to the OTU name before matching, and before the modifiers below. Only one may be active at a time."
        >
          Strip
        </label>
        <label
          v-for="preset in STRIP_PRESETS"
          :key="preset.label"
          class="middle"
        >
          <input
            type="radio"
            :value="preset.value"
            :checked="stripPreset === preset.value"
            @change="handleStripChange(preset.value)"
          />
          {{ preset.label }}
        </label>
      </div>

      <!-- Fuzzy match slider -->
      <div class="field margin-medium-bottom">
        <label>
          Fuzzy match (Levenshtein distance: {{ levenshteinDistance }})
        </label>
        <input
          type="range"
          min="0"
          max="8"
          :value="levenshteinDistance"
          class="full_width"
          @input="handleLevenshteinChange"
        />
        <div class="flex-row flex-separate">
          <span class="subtle">Exact</span>
          <span class="subtle">8</span>
        </div>
      </div>

      <!-- Author/year -->
      <div class="field margin-medium-bottom">
        <label
          class="middle"
          data-help="When the OTU name carries an author and year, match on the name alone, then use the author/year to choose between multiple candidates."
        >
          <input
            type="checkbox"
            :checked="useAuthorYear"
            @change="handleAuthorYearChange"
          />
          Use author/year
        </label>
      </div>

      <!-- Modifiers -->
      <div class="field">
        <label
          data-help="Regex find-and-replace rules applied to the match string after the strip rule above. Each active row is applied in sequence."
        >
          Modifiers
        </label>
        <div class="modifier-header">
          <span />
          <span class="subtle">Replace this</span>
          <span class="subtle">With this</span>
          <span />
        </div>
        <div
          v-for="(modifier, index) in modifiers"
          :key="index"
          class="modifier-row margin-small-bottom"
        >
          <input
            type="checkbox"
            :checked="modifier.active"
            @change="updateModifier(index, 'active', $event.target.checked)"
          />
          <input
            type="text"
            class="normal-input modifier-input"
            placeholder="Replace this"
            :value="modifier.pattern"
            @input="updateModifier(index, 'pattern', $event.target.value)"
          />
          <input
            type="text"
            class="normal-input modifier-input"
            placeholder="With this"
            :value="modifier.replacement"
            @input="updateModifier(index, 'replacement', $event.target.value)"
          />
          <VBtn
            circle
            color="primary"
            title="Remove this row"
            @click="removeModifier(index)"
          >
            <VIcon
              x-small
              name="trash"
            />
          </VBtn>
        </div>

        <VBtn
          color="primary"
          medium
          class="margin-small-top"
          @click="addModifier"
        >
          Add row
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { STRIP_PRESETS } from '../constants'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'

defineProps({
  taxonNameFilterUrl: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['reset', 'update-options'])

const scopeTaxonName = defineModel('scopeTaxonName', {
  type: Object,
  default: undefined
})
const stripPreset = defineModel('stripPreset', {
  type: String,
  default: null
})
const levenshteinDistance = defineModel('levenshteinDistance', {
  type: Number,
  default: 0
})
const useAuthorYear = defineModel('useAuthorYear', {
  type: Boolean,
  default: false
})
const modifiers = defineModel('modifiers', { type: Array })

let debounceTimer = null

function debouncedUpdate() {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    emit('update-options')
  }, 500)
}

function handleReset() {
  clearTimeout(debounceTimer)
  emit('reset')
}

function handleScopeSelect(item) {
  scopeTaxonName.value = item
  emit('update-options')
}

function clearScope() {
  scopeTaxonName.value = null
  emit('update-options')
}

function handleStripChange(value) {
  stripPreset.value = value
  emit('update-options')
}

function handleLevenshteinChange(event) {
  levenshteinDistance.value = parseInt(event.target.value)
  debouncedUpdate()
}

function handleAuthorYearChange(event) {
  useAuthorYear.value = event.target.checked
  emit('update-options')
}

function updateModifier(index, field, value) {
  const updated = [...modifiers.value]
  updated[index] = { ...updated[index], [field]: value }
  modifiers.value = updated
  debouncedUpdate()
}

function addModifier() {
  modifiers.value = [
    ...modifiers.value,
    { active: false, pattern: '', replacement: '' }
  ]
}

function removeModifier(index) {
  modifiers.value = modifiers.value.filter((_, i) => i !== index)
  debouncedUpdate()
}
</script>

<style scoped>
.match-options-panel {
  min-width: 320px;
}

.modifier-header,
.modifier-row {
  display: grid;
  grid-template-columns: 20px 1fr 1fr 28px;
  gap: 0.5em;
  align-items: center;
}

.modifier-input {
  width: 100%;
}
</style>
