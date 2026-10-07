<template>
  <VModal
    :containerStyle="{ width: '500px' }"
    v-if="showModal"
    @close="emit('close')"
  >
    <template #header>
      <h3>Select OTU</h3>
    </template>
    <template #body>
      <p class="separate-bottom">
        This taxon name has more than one OTU. Select the one to browse.
      </p>
      <ul class="no_bullets">
        <li
          v-for="otu in otus"
          :key="otu.id"
        >
          <label class="horizontal-left-content middle">
            <input
              type="radio"
              name="select-otu"
              :checked="otuSelected?.id === otu.id"
              @change="setOtu(otu)"
            />
            <span v-html="otu.object_tag" />
          </label>
        </li>
      </ul>
    </template>
  </VModal>
</template>

<script setup>
import { computed, ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'

const props = defineProps({
  otus: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['selected', 'close'])

const otuSelected = ref()

// Selecting navigates away, so the modal closes while the browser loads the new
// page and a second click cannot start a second navigation.
const showModal = computed(() => props.otus.length && !otuSelected.value)

function setOtu(otu) {
  otuSelected.value = otu

  emit('selected', otu)
}
</script>
