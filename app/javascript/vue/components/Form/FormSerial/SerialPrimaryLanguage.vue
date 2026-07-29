<template>
  <div class="field label-above">
    <label>Primary language</label>
    <div class="horizontal-left-content gap-small">
      <VAutocomplete
        url="/languages/autocomplete"
        param="term"
        label="label"
        display="label"
        placeholder="Select a language"
        :send-label="languageLabel"
        @get-item="setLanguage"
      />
      <VBtn
        v-if="primaryLanguageId"
        color="primary"
        icon
        variant="tonal"
        title="Remove language"
        @click="unset"
      >
        <IconReset class="w-4 h-4" />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Language } from '@/routes/endpoints'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconReset from '@/components/Icon/IconReset.vue'

const primaryLanguageId = defineModel({
  type: Number,
  default: undefined
})

const languageLabel = ref('')

watch(
  primaryLanguageId,
  (newVal) => {
    if (!newVal) {
      languageLabel.value = ''
      return
    }

    Language.find(newVal).then(({ body }) => {
      languageLabel.value = body.english_name
    })
  },
  { immediate: true }
)

function setLanguage({ id, label }) {
  languageLabel.value = label
  primaryLanguageId.value = id
}

function unset() {
  languageLabel.value = ''
  primaryLanguageId.value = undefined
}
</script>
