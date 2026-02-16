<template>
  <div class="match-options-panel panel content">
    <div class="flex-row flex-separate middle margin-medium-bottom">
      <h3>Match options</h3>
      <VBtn
        color="primary"
        @click="emit('clear-all')"
      >
        Clear all matches
      </VBtn>
    </div>

    <!-- Scope to TaxonName -->
    <div class="flex-col gap-medium">
      <div class="field margin-medium-bottom">
        <label>Scope to TaxonName</label>
        <template v-if="filterResultLink && scopeTaxonNameId">
          <span class="filter-result-link">
            Filter result (ID: {{ scopeTaxonNameId }})
          </span>
        </template>
        <template v-else>
          <Autocomplete
            url="/taxon_names/autocomplete"
            param="term"
            label="label_html"
            :clear-after="false"
            placeholder="Search taxon name to scope..."
            @getItem="handleScopeSelect"
          />
        </template>
        <div
          v-if="scopeTaxonNameId && !filterResultLink"
          class="margin-small-top horizontal-left-content gap-small"
        >
          <span class="subtle">Scoped to ID: {{ scopeTaxonNameId }}</span>
          <VBtn
            circle
            color="primary"
            @click="clearScope"
          >
            <VIcon
              x-small
              name="close"
            />
          </VBtn>
        </div>
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

      <!-- Resolve synonyms -->
      <div class="field margin-medium-bottom">
        <label class="middle">
          <input
            type="checkbox"
            :checked="resolveSynonyms"
            @change="handleResolveSynonymsChange"
          />
          Resolve synonyms
        </label>
        <span class="subtle">
          When checked, OTUs for valid TaxonNames of synonyms are selected.
        </span>
      </div>

      <!-- Modifiers -->
      <div class="field">
        <label>Modifiers</label>
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
            class="normal-input"
            placeholder="Replace this"
            :value="modifier.pattern"
            @input="updateModifier(index, 'pattern', $event.target.value)"
          />
          <input
            type="text"
            class="normal-input"
            placeholder="With this"
            :value="modifier.replacement"
            @input="updateModifier(index, 'replacement', $event.target.value)"
          />
          <VBtn
            circle
            color="primary"
            @click="removeModifier(index)"
          >
            <VIcon
              x-small
              name="trash"
            />
          </VBtn>
        </div>

        <div class="flex-row gap-small margin-small-top">
          <VBtn
            color="primary"
            medium
            @click="addModifier"
          >
            Add row
          </VBtn>
          <select
            class="normal-input"
            @change="
              (e) => {
                addCommonReplacement(e.target.value)
                e.target.value = ''
              }
            "
          >
            <option value="">Add common replacement</option>
            <option value="removeSp">Remove sp.</option>
            <option value="removeFirstWord">Remove first word</option>
            <option value="removeLastWord">Remove last word</option>
            <option value="keepFirstTwo">Keep only first two words</option>
            <option value="removeTrailingId">Remove trailing ID</option>
          </select>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'

defineProps({
  filterResultLink: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['clear-all', 'update-options'])

const scopeTaxonNameId = defineModel('scopeTaxonNameId', { type: Number })
const levenshteinDistance = defineModel('levenshteinDistance', {
  type: Number,
  default: 0
})
const resolveSynonyms = defineModel('resolveSynonyms', {
  type: Boolean,
  default: false
})
const modifiers = defineModel('modifiers', { type: Array })

const COMMON_REPLACEMENTS = {
  removeSp: { pattern: 'sp\\.\\s*', replacement: '' },
  removeFirstWord: { pattern: '^\\S+\\s*', replacement: '' },
  removeLastWord: { pattern: '\\s+\\S+$', replacement: '' },
  keepFirstTwo: { pattern: '^(\\S+\\s+\\S+).*', replacement: '$1' },
  removeTrailingId: { pattern: '\\s+\\d+$', replacement: '' }
}

let debounceTimer = null

function debouncedUpdate() {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    emit('update-options')
  }, 500)
}

function handleScopeSelect(item) {
  scopeTaxonNameId.value = item.id
  emit('update-options')
}

function clearScope() {
  scopeTaxonNameId.value = null
  emit('update-options')
}

function handleLevenshteinChange(event) {
  levenshteinDistance.value = parseInt(event.target.value)
  debouncedUpdate()
}

function handleResolveSynonymsChange(event) {
  resolveSynonyms.value = event.target.checked
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

function addCommonReplacement(key) {
  if (!key || !COMMON_REPLACEMENTS[key]) return
  const { pattern, replacement } = COMMON_REPLACEMENTS[key]
  modifiers.value = [...modifiers.value, { active: true, pattern, replacement }]
  debouncedUpdate()
}
</script>

<style scoped>
.match-options-panel {
  min-width: 350px;
  max-width: 400px;
}

.modifier-row {
  display: flex;
  align-items: center;
  gap: 4px;
}

.subtle {
  color: #888;
  font-size: 0.85em;
}

.filter-result-link {
  color: #5bc0de;
  font-weight: bold;
}

.field label {
  font-weight: bold;
  display: block;
  margin-bottom: 4px;
}
</style>
