<template>
  <div class="full_width">
    <div class="horizontal-left-content full_width gap-small">
      <VAutocomplete
        ref="autocomplete"
        url="/sources/autocomplete"
        min="3"
        param="term"
        label="label_html"
        placeholder="Type a source..."
        display="label"
        clear-after
        :disabled="isSaving"
        @getItem="({ id }) => setSource({ id, pages: citation?.pages })"
      />
      <ButtonPinned
        label="source"
        type="Source"
        section="Sources"
        :disabled="isSaving"
        @get-item="({ id }) => setSource({ id, pages: citation?.pages })"
      />
      <FormCitationClone
        :disabled="isSaving"
        @clone="(c) => setSource({ id: c.source_id, pages: c.pages })"
      />
      <VBtn
        color="primary"
        variant="tonal"
        icon
        medium
        :href="RouteNames.NewSource"
        title="Add new source"
      >
        <IconBookPlus class="w-4 h-4" />
      </VBtn>
    </div>

    <div
      v-if="citation"
      class="flex-separate middle gap-small margin-medium-top"
    >
      <div>
        <span
          class="break_words"
          v-html="citation.source.cached"
        />
        <span class="padding-xsmall">
          <SoftValidation
            :validate-object="citation"
            :global-id="citation.global_id"
          />
        </span>
      </div>
      <div class="horizontal-left-content gap-small">
        <CitationPages
          :citation="citation"
          :disabled="isSaving"
          @setPages="addPages"
          @save="triggerSave"
        />
        <PdfButton
          v-if="citation.hasOwnProperty('target_document')"
          :pdf="citation.target_document"
        />
        <RadialAnnotator
          type="annotations"
          :global-id="citation.source.global_id"
        />
        <RadialObject :global-id="citation.source.global_id" />
        <VBtn
          icon
          color="destroy"
          variant="tonal"
          @click="removeSource(taxon.origin_citation.id)"
        >
          <IconTrash class="w-4 h-4" />
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { useStore } from 'vuex'
import { computed, ref } from 'vue'

import VAutocomplete from '@/components/ui/Autocomplete.vue'
import ButtonPinned from '@/components/ui/Button/ButtonPinned.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial'
import PdfButton from '@/components/ui/Button/ButtonPdf'
import CitationPages from '../citationPages.vue'
import SoftValidation from '@/components/soft_validations/objectValidation.vue'
import FormCitationClone from '@/components/Form/FormCitation/FormCitationClone.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'

import { RouteNames } from '@/routes/routes.js'
import IconBookPlus from '@/components/Icon/IconBookPlus.vue'

const autocomplete = ref(null)

let autosave = null

const store = useStore()
const citation = computed(() => store.getters[GetterNames.GetCitation])
const taxon = computed({
  get() {
    return store.getters[GetterNames.GetTaxon]
  },
  set(value) {
    store.commit(MutationNames.SetTaxon, value)
  }
})

const isAutosaveActive = computed(() => store.getters[GetterNames.GetAutosave])
const isSaving = computed(() => store.getters[GetterNames.GetSaving])

function setSource({ id, pages }) {
  if (isSaving.value) return

  const payload = {
    id,
    pages: pages || null
  }

  store.dispatch(ActionNames.ChangeTaxonSource, payload)
  store.dispatch(ActionNames.UpdateTaxonName, taxon.value)
}

function addPages(citation) {
  const newSource = {
    id: citation.source_id,
    pages: citation?.pages || null
  }
  store.dispatch(ActionNames.ChangeTaxonSource, newSource)

  clearTimeout(autosave)

  if (isAutosaveActive.value) {
    autosave = setTimeout(() => {
      triggerSave(citation)
    }, 3000)
  }
}

function triggerSave(citation) {
  clearTimeout(autosave)
  store.dispatch(ActionNames.UpdateSource, citation)
}

function removeSource(id) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure you want to proceed?"
    )
  ) {
    store.dispatch(ActionNames.RemoveSource, id)
  }
}

function focus() {
  autocomplete.value?.setFocus()
}

defineExpose({ focus })
</script>
