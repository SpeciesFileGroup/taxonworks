<template>
  <div class="panel content">
    <div class="separate-bottom">
      <label for="observation_ids">Enter iNaturalist observation IDs or URLs, one per line.</label>
      <div class="horizontal-left-content middle gap-small margin-large-top">
        <VSwitch
          v-model="mode"
          name="inat-mode"
          :options="['Import', 'Find']"
        />
        <em>Maximum {{ mode === 'Import' ? IMPORT_LIMIT : FIND_LIMIT }} per submission.</em>
      </div>
      <textarea
        id="observation_ids"
        v-model="rawInput"
        rows="6"
        class="observation-input"
        :placeholder="`99182856\nhttps://www.inaturalist.org/observations/12345678`"
      />
      <span
        v-if="parsedIds.length"
        class="subtle"
      >
        {{ parsedIds.length }} observation{{ parsedIds.length === 1 ? '' : 's' }}
      </span>
    </div>

    <template v-if="mode === 'Import'">
      <div class="separate-bottom">
        <label>
          <input
            type="checkbox"
            v-model="options.import_images"
          />
          Import images (CC license only)
        </label>
      </div>

      <div class="separate-bottom">
        <label>
          <input
            type="checkbox"
            v-model="options.import_sounds"
          />
          Import sounds (CC license only)
        </label>
      </div>

      <div class="separate-bottom">
        <label>
          <input
            type="checkbox"
            v-model="options.use_community_taxon"
          />
          Use iNat community taxon determination (uncheck to use observer's own identification instead)
        </label>
      </div>

      <div class="separate-bottom">
        <label>
          <input
            type="checkbox"
            v-model="options.match_otu_by_name"
          />
          Match OTU by taxon name (tries existing OTU in project first; creates name-only OTU if none found)
        </label>
      </div>
    </template>

    <VBtn
      color="primary"
      class="submit-btn"
      :disabled="!canSubmit"
      @click="submit"
    >
      {{ isSubmitting ? 'Looking up observations…' : (mode === 'Import' ? 'Queue import' : 'Find') }}
    </VBtn>
    <div
      v-if="mode === 'Import'"
      class="margin-medium-top"
    >
      iNaturalist observations are imported in the background; after submission, click the Refresh button in the Recents table to track import progress.
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import { FieldOccurrence } from '@/routes/endpoints'

const IMPORT_LIMIT = 50
const FIND_LIMIT = 200

const emit = defineEmits(['submitted'])

defineOptions({ name: 'ImportForm' })

const rawInput = ref('')
const isSubmitting = ref(false)
const mode = ref('Import')

const options = reactive({
  use_community_taxon: true,
  match_otu_by_name: true,
  import_images: true,
  import_sounds: true
})

const parsedIds = computed(() =>
  rawInput.value
    .split('\n')
    .map(line => line.trim())
    .filter(Boolean)
    .flatMap(line => {
      const match = line.match(/^(?:https?:\/\/(?:www\.)?inaturalist\.org\/observations\/)?(\d+)\s*$/)
      return match ? [match[1]] : []
    })
)

const canSubmit = computed(() =>
  parsedIds.value.length > 0 &&
  parsedIds.value.length <= (mode.value === 'Import' ? IMPORT_LIMIT : FIND_LIMIT) &&
  !isSubmitting.value
)

async function submit() {
  if (!canSubmit.value) return

  const findOnly = mode.value === 'Find'
  isSubmitting.value = true
  try {
    const call = findOnly ? FieldOccurrence.iNatFind : FieldOccurrence.iNatImport
    const params = findOnly ? { observation_ids: parsedIds.value } : { observation_ids: parsedIds.value, ...options }
    const { body } = await call(params)

    const parts = []
    if (findOnly) {
      const found = body.summary.filter(r => r.status === 'found').length
      const notImported = body.summary.filter(r => r.status === 'not_imported').length
      const notFound = body.summary.filter(r => r.status === 'not_found').length
      if (found) parts.push(`${found} found in this project`)
      if (notImported) parts.push(`${notImported} not yet imported`)
      if (notFound) parts.push(`${notFound} not found on iNaturalist`)
    } else {
      const queued = body.summary.filter(r => r.status === 'queued').length
      const existing = body.summary.filter(r => r.status === 'already_imported').length
      const notFound = body.summary.filter(r => r.status === 'not_found').length
      const noTaxon = body.summary.filter(r => r.status === 'no_taxon').length
      if (queued) parts.push(`${queued} queued`)
      if (existing) parts.push(`${existing} already imported`)
      if (notFound) parts.push(`${notFound} not found on iNaturalist`)
      if (noTaxon) parts.push(`${noTaxon} skipped (no taxon)`)
    }

    TW.workbench.alert.create(parts.join('; '), 'notice')
    emit('submitted', body.summary)
  } finally {
    isSubmitting.value = false
  }
}
</script>

<style scoped>
.submit-btn {
  align-self: flex-start;
}

.observation-input {
  width: 100%;
  display: block;
}
</style>
