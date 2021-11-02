<template>
  <div class="full_width">
    <div class="horizontal-left-content full_width margin-medium-bottom">
      <autocomplete
        class="full_width"
        url="/sources/autocomplete"
        min="3"
        param="term"
        label="label_html"
        placeholder="Search a source..."
        display="label"
        clear-after
        @getItem="setSource($event.id)"
      />
      <default-element
        class="margin-small-left"
        label="source"
        type="Source"
        section="Sources"
        @getId="setSource"
      />
    </div>

    <template v-if="source">
      <div class="flex-separate middle">
        <span>
          <span
            target="_blank"
            v-html="source.cached"
          />
          <soft-validation
            v-if="combination.origin_citation_attributes.id"
            :validate-object="combination.origin_citation_attributes"
            :global-id="combination.origin_citation_attributes.global_id"/>
        </span>
        <div
          class="horizontal-left-content">
          <input
            class="pages"
            type="text"
            placeholder="Pages"
            v-model="combination.origin_citation_attributes.pages"
          >
          <pdf-button
            v-if="combination.origin_citation_attributes.hasOwnProperty('target_document')"
            :pdf="combination.origin_citation_attributes.target_document"
          />
          <radial-object
            v-if="source"
            :global-id="source.global_id"
          />
          <radial-annotator
            v-if="source"
            type="annotations"
            :global-id="source.global_id"
          />
          <v-btn
            class="circle-button"
            circle
            color="destroy"
            @click="removeSource(combination.origin_citation_attributes.id)">
            <v-icon
              x-small
              name="trash"
            />
          </v-btn>
        </div>
      </div>
    </template>
  </div>
</template>
<script setup>

import { computed, ref, watch } from 'vue'
import { Source, Citation } from 'routes/endpoints'
import Autocomplete from 'components/ui/Autocomplete.vue'
import DefaultElement from 'components/getDefaultPin.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/navigation/radial'
import PdfButton from 'components/pdfButton'
import SoftValidation from 'components/soft_validations/objectValidation.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const combination = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const source = ref(undefined)

watch(() => combination.value.origin_citation_attributes.source_id, async id => {
  source.value = id
    ? (await Source.find(id)).body
    : undefined
}, { immediate: true })

const setSource = sourceId => {
  combination.value.origin_citation_attributes.source_id = sourceId
}

const removeSource = () => {
  if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
    const citationId = combination.value.origin_citation_attributes.id

    if (citationId) {
      Citation.destroy(citationId)
    }

    combination.value.origin_citation_attributes.id = undefined
    setSource()
  }
}
</script>
