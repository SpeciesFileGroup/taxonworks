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
          <a :href="RouteNames.ManageBiocurationTask">
            Manage biocuration classes and groups
          </a>
        </li>
        <li>
          <a :href="RouteNames.BiologicalRelationshipComposer">
            Biological relationship composer
          </a>
        </li>
      </ul>
    </div>

    <VSwitch
      v-model="type"
      :options="Object.keys(CVT_TYPES)"
    />
    <div class="flex-separate middle">
      <h3>
        {{ CVT_TYPES[type] }}
        <a
          v-if="linkFor.includes(type)"
          href="/tasks/controlled_vocabularies/biocuration/build_collection"
          >Manage biocuration classes and groups
        </a>
      </h3>
      <CloneControlledVocabularyTerms
        :type="type"
        @clone="
          () => {
            loadCVTList(type)
          }
        "
      />
    </div>
    <div class="flex-separate margin-medium-top">
      <NavBar
        class="one_quarter_width"
        navbar-class=""
      >
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
      </NavBar>
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
import { computed, ref, watch, onMounted } from 'vue'
import { ControlledVocabularyTerm } from '@/routes/endpoints'
import { addToArray, removeFromArray } from '@/helpers'
import { RouteNames } from '@/routes/routes'
import { setParam } from '@/helpers'
import { KEYWORD, BIOCURATION_CLASS, BIOCURATION_GROUP } from '@/constants'
import CVT_TYPES from './constants/controlled_vocabulary_term_types'
import makeControlledVocabularyTerm from '@/factory/controlledVocabularyTerm'
import VSwitch from '@/components/ui/VSwitch.vue'
import ListComponent from './components/List.vue'
import SpinnerComponent from '@/components/ui/VSpinner'
import FormKeyword from '@/components/Form/FormKeyword.vue'
import CloneFromObject from '@/helpers/cloneFromObject'
import CloneControlledVocabularyTerms from './components/CloneControlledVocabularyTerms.vue'
import NavBar from '@/components/layout/NavBar.vue'

const globalId = computed(() => cvt.value?.global_id)
const cvt = ref(makeControlledVocabularyTerm())
const isSaving = ref(false)
const isLoading = ref(false)
const type = ref(null)
const linkFor = ref([BIOCURATION_CLASS, BIOCURATION_GROUP])
const list = ref([])

watch(type, (newVal) => {
  loadCVTList(newVal)
  setParam(RouteNames.ManageControlledVocabularyTask, 'type', type.value)
})

onMounted(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const ctvId = urlParams.get('controlled_vocabulary_term_id')
  const typeParam = urlParams.get('type')

  if (/^\d+$/.test(ctvId)) {
    ControlledVocabularyTerm.find(ctvId).then(({ body }) => {
      type.value = body.type
      setCTV(body)
    })
  } else {
    type.value = typeParam || KEYWORD
  }
})

function loadCVTList(type) {
  isLoading.value = true
  ControlledVocabularyTerm.where({ type: [type] })
    .then(({ body }) => {
      list.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}

function createCTV() {
  const payload = {
    controlled_vocabulary_term: {
      ...cvt.value,
      type: type.value
    }
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
      cvt.value = makeControlledVocabularyTerm()
    })
    .finally(() => {
      isSaving.value = false
    })
}

function setCTV(ctv) {
  cvt.value = CloneFromObject(makeControlledVocabularyTerm(), ctv)
}

function copyToClipboard() {
  navigator.clipboard.writeText(cvt.value.global_id).then(() => {
    TW.workbench.alert.create('Copied to clipboard', 'notice')
  })
}

function removeCTV(cvt) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    isLoading.value = true
    ControlledVocabularyTerm.destroy(cvt.id)
      .then(() => {
        removeFromArray(list.value, cvt)
      })
      .catch(() => {})
      .finally(() => {
        isLoading.value = false
      })
  }
}
</script>
