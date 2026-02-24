<template>
  <div class="attribution_annotator">
    <VSpinner
      v-if="isLoading"
      legend="Loading..."
    />
    <VSpinner
      v-if="isSaving"
      legend="Updating..."
    />
    <p>
      <i>Only one piece of data can be added/removed/replaced at a time - this
      keeps result counts precise.</i>
    </p>
    <h3>Mode</h3>
    <div class="margin-small-bottom">
      <ul class="no_bullets">
        <li
          v-for="(value, key) in MODE"
          :key="key"
        >
          <label>
            <input
              type="radio"
              :value="value"
              v-model="selectedMode"
            />
            {{ key }}
          </label>
        </li>
      </ul>
    </div>

    <component
      :is="selectedMode.component"
      :klass="klass"
      :licenses="licenses"
      :role-types="roleTypes"
      @select="makeBatchRequest"
    />

    <ConfirmationModal
      ref="confirmationModalRef"
      :container-style="{ 'min-width': 'auto', width: '300px' }"
    />

    <VModal
      v-if="isTableVisible"
      @close="() => (isTableVisible = false)"
    >
      <template #header>
        <h3>Response</h3>
      </template>
      <template #body>
        <PreviewTable :data="response" />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { computed, ref, shallowRef, onMounted } from 'vue'
import { Attribution } from '@/routes/endpoints'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import AttributionAdd from './AttributionAdd.vue'
import AttributionRemove from './AttributionRemove.vue'
import AttributionReplace from './AttributionReplace.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import PreviewTable from '@/components/radials/shared/PreviewTable.vue'
import VModal from '@/components/ui/Modal.vue'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  },

  parameters: {
    type: Object,
    default: undefined
  },

  nestedQuery: {
    type: Boolean,
    default: false
  }
})

const MODE = {
  Add: { mode: 'add', component: AttributionAdd },
  Remove: { mode: 'remove', component: AttributionRemove },
  Replace: { mode: 'replace', component: AttributionReplace }
}

const isLoading = ref(true)
const isSaving = ref(false)
const isTableVisible = ref(false)
const confirmationModalRef = ref(null)
const response = ref(null)
const selectedMode = shallowRef(MODE.Add)
const licenses = ref([])
const roleTypes = ref([])

onMounted(() => {
  Promise.all([
    Attribution.licenses(),
    Attribution.roleTypes()
  ]).then(([licensesResponse, roleTypesResponse]) => {
    licenses.value = [
      ...Object.entries(licensesResponse.body).map(([key, { name, link }]) => ({
        key,
        label: `${name}: ${link}`
      })),
      { label: '-- None --', key: null }
    ]

    roleTypes.value = roleTypesResponse.body
  }).finally(() => {
    isLoading.value = false
  })
})

const queryParam = computed(() => [QUERY_PARAM[props.objectType]])
const klass = computed(() => props.objectType)

async function makeBatchRequest(data) {
  const ok = await confirmationModalRef.value.show({
    title: 'Attributions',
    message: 'Are you sure you want to proceed?',
    confirmationWord: 'UPDATE',
    okButton: selectedMode.value.mode === 'add' ? 'Create' : 'Update',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (ok) {
    const idParam = ID_PARAM_FOR[props.objectType]
    const payload = Array.isArray(data)
      ? makeReplacePayload(data)
      : makePayload(data)

    if (props.ids?.length) {
      payload.filter_query[queryParam.value][idParam] = props.ids
    }

    isSaving.value = true
    Attribution.batchByFilter(payload)
      .then(({ body }) => {
        response.value = body
        isTableVisible.value = true
      })
      .catch(() => {})
      .finally(() => {
        isSaving.value = false
      })
  }
}

function makePayload(data) {
  return {
    filter_query: filterQuery(),
    mode: selectedMode.value.mode,
    params: {
      attribution: data
    }
  }
}

function makeReplacePayload([replace, to]) {
  return {
    filter_query: filterQuery(),
    mode: selectedMode.value.mode,
    params: {
      attribution: to,
      replace_attribution: replace
    }
  }
}

function filterQuery() {
  return props.nestedQuery
    ? props.parameters
    : { [QUERY_PARAM[props.objectType]]: props.parameters }
}
</script>
