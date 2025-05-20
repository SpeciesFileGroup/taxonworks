<template>
  <div class="full_width">
    <div class="horizontal-left-content full_width gap-small">
      <VAutocomplete
        url="/sources/autocomplete"
        min="3"
        param="term"
        label="label_html"
        placeholder="Type a source..."
        display="label"
        clear-after
        @getItem="({id}) => setSource({ id, pages: citation?.pages })"
      />
      <ButtonPinned
        label="source"
        type="Source"
        section="Sources"
        @get-item="({id}) => setSource({ id, pages: citation?.pages })"
      />
      <FormCitationClone
        @clone="(c) => setSource({ id: c.source_id, pages: c.pages })"
      />
    </div>
    <hr />
    <div v-if="citation">
      <div class="flex-separate middle">
        <p>
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
        </p>
        <div class="horizontal-left-content gap-small">
          <CitationPages
            @setPages="addPages"
            @save="triggerSave"
            :citation="taxon"
          />
          <PdfButton
            v-if="citation.hasOwnProperty('target_document')"
            :pdf="citation.target_document"
          />
          <RadialObject :global-id="citation.source.global_id" />
          <RadialAnnotator
            type="annotations"
            :global-id="citation.source.global_id"
          />
          <span
            class="circle-button btn-delete"
            @click="removeSource(taxon.origin_citation.id)"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { useStore } from 'vuex'
import { computed } from 'vue'

import VAutocomplete from '@/components/ui/Autocomplete.vue'
import ButtonPinned from '@/components/ui/Button/ButtonPinned.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/navigation/radial'
import PdfButton from '@/components/ui/Button/ButtonPdf'
import CitationPages from '../citationPages.vue'
import SoftValidation from '@/components/soft_validations/objectValidation.vue'
import FormCitationClone from '@/components/Form/FormCitation/FormCitationClone.vue'

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

function setSource({ id, pages }) {
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
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    store.dispatch(ActionNames.RemoveSource, id)
  }
}
</script>
