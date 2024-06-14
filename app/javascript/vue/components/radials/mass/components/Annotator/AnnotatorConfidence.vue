<template>
  <div class="confidence_annotator">
    <SmartSelector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'ConfidenceLevel' }"
      get-url="/controlled_vocabulary_terms/"
      model="confidence_levels"
      button-class="button-submit"
      buttons
      inline
      klass="Tag"
      :target="objectType"
      :custom-list="{ all: allList }"
      @selected="createConfidence"
    />
    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />
  </div>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm, Confidence } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import confirmationOpts from '../../constants/confirmationOpts.js'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['create'])

const confirmationModalRef = ref(null)
const allList = ref([])

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: ['ConfidenceLevel'] }).then(
    ({ body }) => {
      allList.value = body
    }
  )
})

async function createConfidence(confidence) {
  const ok = await confirmationModalRef.value.show(confirmationOpts)

  if (ok) {
    const promises = props.ids.map((id) => {
      const payload = {
        confidence_level_id: confidence.id,
        confidence_object_id: id,
        confidence_object_type: props.objectType
      }

      return Confidence.create({ confidence: payload })
    })

    Promise.all(promises).then(() => {
      emit(
        'create',
        promises.map((r) => r.body)
      )
      TW.workbench.alert.create(
        'Note item(s) were successfully created',
        'notice'
      )
    })
  }
}
</script>
