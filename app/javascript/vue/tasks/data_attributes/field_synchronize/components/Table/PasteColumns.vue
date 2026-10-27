<template>
  <VModal
    v-if="isModalVisible"
    :container-style="{
      width: '600px'
    }"
    @close="cancel"
  >
    <template #header>
      <h3>Paste columns</h3>
    </template>
    <template #body>
      <p>
        Pasting {{ rowCount }} row(s) into {{ columnLabels.length }} column(s):
        {{ columnLabels.join(', ') }}
      </p>

      <h4>Mode</h4>
      <ul class="no_bullets">
        <li>
          <label>
            <input
              type="radio"
              :value="false"
              v-model="replaceAll"
            />
            Fill empty cells
          </label>
        </li>
        <li>
          <label>
            <input
              type="radio"
              :value="true"
              v-model="replaceAll"
            />
            Replace all cells
          </label>
        </li>
      </ul>

      <p class="margin-medium-top">
        This operation will update {{ total }} cell(s).
      </p>

      <ul v-if="warnings.length">
        <li
          v-for="(warning, index) in warnings"
          :key="index"
        >
          {{ warning }}
        </li>
      </ul>

      <div
        v-if="needsConfirmationWord"
        class="margin-medium-top"
      >
        <p>Type "{{ CONFIRMATION_WORD }}" to proceed.</p>
        <input
          type="text"
          class="full_width"
          ref="confirmationInputRef"
          v-model="confirmationText"
          :placeholder="`Write ${CONFIRMATION_WORD} to continue`"
          @keydown.enter="isConfirmed && submit()"
        />
      </div>
    </template>
    <template #footer>
      <VBtn
        color="update"
        medium
        :disabled="!isConfirmed"
        @click="submit"
      >
        Update
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { computed, nextTick, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal'

const CONFIRMATION_WORD = 'UPDATE'

const props = defineProps({
  maxRecordsWithoutConfirmation: {
    type: Number,
    default: 10
  }
})

const isModalVisible = ref(false)
const rejectPromise = ref(null)
const resolvePromise = ref(null)
const confirmationInputRef = ref(null)

const replaceAll = ref(false)
const confirmationText = ref('')
const rowCount = ref(0)
const columnLabels = ref([])
const totalReplace = ref(0)
const totalFillEmpty = ref(0)
const skipped = ref({})

const total = computed(() =>
  replaceAll.value ? totalReplace.value : totalFillEmpty.value
)

const needsConfirmationWord = computed(
  () => total.value > props.maxRecordsWithoutConfirmation
)

const isConfirmed = computed(
  () =>
    !!total.value &&
    (!needsConfirmationWord.value ||
      confirmationText.value.toLowerCase() === CONFIRMATION_WORD.toLowerCase())
)

const warnings = computed(() => {
  const messages = []
  const { rows, columns, noEditable, ambiguous } = skipped.value

  if (rows) {
    messages.push(
      `${rows} pasted row(s) fall below the last row of this page and were ignored.`
    )
  }

  if (columns) {
    messages.push(
      `${columns} pasted cell(s) fall beyond the last column and were ignored.`
    )
  }

  if (noEditable) {
    messages.push(
      `${noEditable} pasted cell(s) target a read-only attribute and were ignored.`
    )
  }

  if (ambiguous) {
    messages.push(
      `${ambiguous} pasted cell(s) target a record with more than one value for that predicate and were ignored.`
    )
  }

  return messages
})

function show(payload) {
  rowCount.value = payload.rowCount
  columnLabels.value = payload.columnLabels
  totalReplace.value = payload.totalReplace
  totalFillEmpty.value = payload.totalFillEmpty
  skipped.value = payload.skipped

  replaceAll.value = false
  confirmationText.value = ''
  isModalVisible.value = true

  nextTick(() => {
    confirmationInputRef.value?.focus()
  })

  return new Promise((resolve, reject) => {
    resolvePromise.value = resolve
    rejectPromise.value = reject
  })
}

function submit() {
  isModalVisible.value = false
  resolvePromise.value({ replace: replaceAll.value })
}

function cancel() {
  isModalVisible.value = false
  rejectPromise.value(false)
}

defineExpose({
  show
})
</script>
