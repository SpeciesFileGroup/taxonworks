<template>
  <div class="flex-col gap-small">
    <div class="horizontal-left-content middle gap-small">
      <VAutocomplete
        class="full_width"
        url="/otus/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search an OTU..."
        clear-after
        @select="selectOtu"
      />
      <ButtonPinned
        section="Otus"
        :type="OTU"
        @get-item="selectOtu"
      />
    </div>

    <template v-if="otu">
      <div class="horizontal-left-content middle gap-small">
        <span
          class="full_width"
          v-html="otu.label"
        />
        <VBtn
          circle
          color="primary"
          variant="ghost"
          title="Clear"
          @click="clear"
        >
          <VIcon
            name="close"
            x-small
          />
        </VBtn>
      </div>

      <VSpinner v-if="isLoading" />
      <p v-else-if="!depictions.length">No depictions for this OTU.</p>
      <SourceThumbnails
        v-else
        :objects="depictions"
        :object-type="DEPICTION"
        noun="depiction"
        :placed-keys="placedKeys"
        @add="(payload) => emit('add', payload)"
      />
    </template>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { DEPICTION, OTU } from '@/constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import ButtonPinned from '@/components/ui/Button/ButtonPinned.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import SourceThumbnails from './SourceThumbnails.vue'

const MAX_DEPICTIONS = 500

defineProps({
  placedKeys: {
    type: Set,
    required: true
  }
})

const emit = defineEmits(['add'])

const otu = ref(null)
const depictions = ref([])
const isLoading = ref(false)

function selectOtu(item) {
  otu.value = { id: item.id, label: item.label_html || item.label }
  depictions.value = []
  isLoading.value = true

  Depiction.filter({
    otu_id: [item.id],
    otu_scope: ['all'],
    per: MAX_DEPICTIONS,
    extend: ['depiction_object']
  })
    .then(({ body }) => {
      depictions.value = body
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}

function clear() {
  otu.value = null
  depictions.value = []
}
</script>
