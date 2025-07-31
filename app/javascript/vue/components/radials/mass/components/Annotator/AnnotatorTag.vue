<template>
  <div class="tag_annotator">
    <div class="horizontal-right-content">
      <a
        target="_blank"
        :href="RouteNames.ManageControlledVocabularyTask"
      >
        New keyword
      </a>
    </div>
    <SmartSelector
      class="margin-medium-bottom"
      autocomplete-url="/controlled_vocabulary_terms/autocomplete"
      :autocomplete-params="{ 'type[]': 'Keyword' }"
      get-url="/controlled_vocabulary_terms/"
      model="keywords"
      buttons
      inline
      klass="Tag"
      :target="objectType"
      :custom-list="{ all: allList }"
      @selected="createWithId"
    />
    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />
  </div>
</template>

<script setup>
import { ControlledVocabularyTerm, Tag } from '@/routes/endpoints'
import { RouteNames } from '@/routes/routes'
import { ref, onBeforeMount } from 'vue'
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

async function createWithId({ id }) {
  const ok = await confirmationModalRef.value.show(confirmationOpts)

  if (ok) {
    Tag.createBatch({
      object_type: props.objectType,
      keyword_id: id,
      object_id: props.ids
    }).then((response) => {
      TW.workbench.alert.create(
        'Tag item(s) were successfully created',
        'notice'
      )
      emit('create', response.body)
    })
  }
}

onBeforeMount(() => {
  ControlledVocabularyTerm.where({ type: ['Keyword'] }).then(({ body }) => {
    allList.value = body
  })
})
</script>
