<template>
  <div>
    <button
      type="button"
      class="button normal-input button-submit navbar-button"
      :disabled="!taxon.id || isSaving"
      @click="() => (isModalVisible = true)"
    >
      Clone
    </button>
    <VModal
      v-show="isModalVisible"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>Clone taxon name</h3>
      </template>
      <template #body>
        <p>
          This will clone the current taxon name with the following information.
        </p>
        <ul class="no_bullets">
          <li
            v-for="field in FIELDS"
            :key="field.value"
          >
            <label>
              <input
                v-model="copyValues"
                :value="field.value"
                :disabled="field.lock"
                type="checkbox"
              />
              {{ field.label }}
            </label>
          </li>
        </ul>
        <p>
          Are you sure you want to proceed? Type "{{ checkWord }}" to proceed.
        </p>
        <input
          type="text"
          class="full_width"
          v-model="inputValue"
          @keypress.enter.prevent="cloneTaxon()"
          ref="inputTextRef"
          :placeholder="`Write ${checkWord} to continue`"
        />
      </template>
      <template #footer>
        <button
          type="button"
          class="button normal-input button-submit"
          :disabled="checkInput"
          @click="cloneTaxon()"
        >
          Clone
        </button>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import { computed, ref, watch, onMounted, nextTick } from 'vue'
import { useStore } from 'vuex'
import VModal from '@/components/ui/Modal.vue'
import platformKey from '@/helpers/getPlatformKey'
import { useHotkey } from '@/composables'

const FIELDS = [
  {
    label: 'Name',
    value: 'name',
    lock: true,
    default: true
  },
  {
    label: 'Parent',
    value: 'parent_id',
    lock: true,
    default: true
  },
  {
    label: 'Rank',
    value: 'rank_class',
    lock: true,
    default: true
  },
  {
    label: 'Author',
    value: 'verbatim_author',
    lock: false,
    default: true
  },
  {
    label: 'Year',
    value: 'verbatim_year',
    lock: false,
    default: true
  },
  {
    label: 'Original source',
    value: 'origin_citation',
    lock: false,
    default: true
  },
  {
    label: 'Persons',
    value: 'taxon_name_author_roles',
    lock: false,
    default: true
  },
  {
    label: 'Original combination relationships',
    value: 'original_combination',
    lock: false,
    default: false
  },
  {
    label: 'Add invalid relationship',
    value: 'invalid_relationship',
    lock: false,
    default: false
  }
]

const store = useStore()

const shortcuts = ref([
  {
    keys: [platformKey(), 'l'],
    preventDefault: true,
    handler() {
      if (taxon.value.id && !isSaving.value) {
        isModalVisible.value = true
      }
    }
  }
])

useHotkey(shortcuts.value)

const inputTextRef = ref(null)
const isModalVisible = ref(false)
const inputValue = ref('')
const checkWord = ref('CLONE')
const copyValues = ref([])

const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const isSaving = computed(() => store.getters[GetterNames.GetSaving])
const checkInput = computed(
  () => inputValue.value.toUpperCase() !== checkWord.value
)

watch(isModalVisible, (newVal) => {
  if (newVal) {
    nextTick(() => {
      inputTextRef.value.focus()
    })
  }
})

onMounted(() => {
  copyValues.value = FIELDS.filter((item) => item.default).map(
    (item) => item.value
  )
})

function cloneTaxon() {
  if (!checkInput.value) {
    store.dispatch(ActionNames.CloneTaxon, copyValues.value)
  }
}
</script>
