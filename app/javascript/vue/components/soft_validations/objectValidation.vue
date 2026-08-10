<template>
  <ul
    v-if="inPlace"
    class="no_bullets"
  >
    <li
      v-for="(validation, index) in validations"
      :key="index"
      class="flex-row gap-small middle padding-small-top padding-small-bottom"
    >
      <IconWarning class="btn-attention w-4 h-4" />
      <span v-html="validation" />
    </li>
  </ul>

  <template v-else>
    <IconCircleQuestionMark
      v-if="isLoading"
      class="text-muted-color w-4 h-4"
      small
      name="question"
      v-tooltip="'Loading validation...'"
    />
    <IconCircleCheckBig
      v-else-if="!validations.length"
      class="w-4 h-4 text-create-color"
      v-tooltip="'Validation passed.'"
    />
    <VBtn
      v-else-if="validations.length"
      icon
      color="attention"
      variant="ghost"
      small
      title="Click to show soft validations"
    >
      <IconWarning
        class="w-4 h-4 cursor-pointer"
        @click="setModalView(true)"
      />
    </VBtn>
    <ModalComponent
      v-if="showModal"
      @close="setModalView(false)"
    >
      <template #header>
        <h3>Soft validation</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <li
            v-for="(validation, index) in validations"
            :key="index"
          >
            <span>
              <IconWarning class="w-4 h-4 text-attention-color" />
              <span
                class="margin-small-left"
                v-html="validation"
              />
            </span>
          </li>
        </ul>
      </template>
    </ModalComponent>
  </template>
</template>

<script setup>
import { ref, watch, onMounted, onBeforeUnmount } from 'vue'
import { SoftValidation } from '@/routes/endpoints'
import { vTooltip } from '@/directives/tooltip.js'
import IconCircleCheckBig from '@/components/Icon/IconCircleCheckBig.vue'
import ModalComponent from '@/components/ui/Modal.vue'
import IconWarning from '@/components/Icon/IconWarning.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconCircleQuestionMark from '../Icon/IconCircleQuestionMark.vue'

const props = defineProps({
  globalId: {
    type: String,
    required: true
  },

  validateObject: {
    type: Object,
    default: undefined
  },

  inPlace: {
    type: Boolean,
    default: false
  }
})

const validations = ref([])
const showModal = ref(false)
const isLoading = ref(false)

let controller

watch(
  () => props.validateObject,
  (newVal) => {
    if (newVal) {
      getSoftValidation()
    }
  },
  { deep: true }
)

onMounted(() => {
  getSoftValidation()
})

onBeforeUnmount(() => {
  controller?.abort()
})

function getSoftValidation() {
  controller?.abort()

  const currentController = new AbortController()

  controller = currentController
  isLoading.value = true

  SoftValidation.find(props.globalId, { signal: currentController.signal })
    .then((response) => {
      if (controller !== currentController) return

      validations.value = response.body.soft_validations.map(
        (validation) => validation.message
      )
    })
    .catch((_) => {})
    .finally(() => {
      if (controller === currentController) {
        isLoading.value = false
      }
    })
}

function setModalView(value) {
  showModal.value = value
}
</script>
