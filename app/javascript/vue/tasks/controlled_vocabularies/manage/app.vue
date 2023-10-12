<template>
  <div>
    <spinner-component
      v-if="isSaving"
      full-screen
      legend="Saving..."
    />

    <div class="flex-separate middle">
      <h1>Manage controlled vocabulary</h1>
      <ul class="context-menu">
        <li>
          <a :href="RouteNames.ManageBiocurationTask"
            >Manage biocuration classes and groups</a
          >
        </li>
      </ul>
    </div>

    <VSwitch
      v-model="view"
      :options="types"
    />
    <div class="flex-separate middle">
      <h3>
        {{ CVT_TYPES[view] }}
        <a
          v-if="linkFor.includes(view)"
          href="/tasks/controlled_vocabularies/biocuration/build_collection"
          >Manage biocuration classes and groups
        </a>
      </h3>
      <CloneControlledVocabularyTerms
        :type="view"
        @clone="
          () => {
            loadCVTList(view)
          }
        "
      />
    </div>
    <div class="flex-separate margin-medium-top">
      <div class="one_quarter_width">
        <div class="panel content margin-medium-bottom">
          <FormKeyword
            v-model="cvt"
            @submit="createCTV"
          />
        </div>
        <div
          v-if="globalId"
          class="panel content"
        >
          <h3>Preview use</h3>
          <span
            class="link"
            @click="copyToClipboard"
            >{{ globalId }}</span
          >
        </div>
      </div>
      <ListComponent
        :list="list"
        @edit="setCTV"
        @remove="removeCTV"
        @sort="
          (data) => {
            list = data
          }
        "
      />
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch, onBeforeMount } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { addToArray } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import CVT_TYPES from './constants/controlled_vocabulary_term_types'
import makeControlledVocabularyTerm from '@/factory/controlledVocabularyTerm'
import VSwitch from '@/components/switch.vue'
import ListComponent from './components/List.vue'
import SpinnerComponent from '@/components/spinner'
import FormKeyword from '@/components/Form/FormKeyword.vue'
import CloneFromObject from '@/helpers/cloneFromObject'
import CloneControlledVocabularyTerms from './components/CloneControlledVocabularyTerms.vue'

const types = computed(() => Object.keys(CVT_TYPES))
const globalId = computed(() => cvt.value?.global_id)
const cvt = ref(makeControlledVocabularyTerm())
const isSaving = ref(false)
const isLoading = ref(false)
const view = ref('Keyword')
const linkFor = ref(['BiocurationClass', 'BiocurationGroup'])
const list = ref([])

watch(
  view,
  (newVal) => {
    cvt.value.type = newVal
    isLoading.value = true
    loadCVTList(newVal)
  },
  {
    immediate: true
  }
)

onBeforeMount(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const ctvId = urlParams.get('controlled_vocabulary_term_id')

  if (/^\d+$/.test(ctvId)) {
    ControlledVocabularyTerm.find(ctvId).then((response) => {
      view.value = response.body.type
      setCTV(response.body)
    })
  }
})

function loadCVTList(type) {
  ControlledVocabularyTerm.where({ type: [type] }).then(({ body }) => {
    list.value = body
    isLoading.value = false
  })
}

function createCTV() {
  const payload = {
    controlled_vocabulary_term: cvt.value
  }
  const request = cvt.value.id
    ? ControlledVocabularyTerm.update(cvt.value.id, payload)
    : ControlledVocabularyTerm.create(payload)

  isSaving.value = true

  request
    .then(({ body }) => {
      TW.workbench.alert.create(
        `${body.type} was successfully ${
          cvt.value.id ? 'updated' : 'created'
        }.`,
        'notice'
      )

      addToArray(list.value, body, { prepend: true })
      newCTV()
    })
    .finally(() => {
      isSaving.value = false
    })
}

function newCTV() {
  cvt.value = makeControlledVocabularyTerm()
  cvt.value.type = view.value
}

function setCTV(ctv) {
  cvt.value = CloneFromObject(makeControlledVocabularyTerm(), ctv)
}

function copyToClipboard() {
  navigator.clipboard.writeText(cvt.value.global_id).then(() => {
    TW.workbench.alert.create('Copied to clipboard', 'notice')
  })
}

function removeCTV(index) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    isLoading.value = true
    ControlledVocabularyTerm.destroy(list.value[index].id)
      .then((_) => {
        list.value.splice(index, 1)
      })
      .finally((_) => {
        isLoading.value = false
      })
  }
}
</script>
