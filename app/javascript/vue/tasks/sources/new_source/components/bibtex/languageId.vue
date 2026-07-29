<template>
  <div>
    <div class="horizontal-left-content">
      <fieldset class="full_width">
        <legend>Language</legend>
        <div class="flex-separate align-start">
          <SmartSelector
            class="full_width"
            model="languages"
            klass="Source"
            label="english_name"
            :filter-ids="source.language_id"
            @selected="setSelected"
          >
            <template #tabs-right>
              <div class="w-full horizontal-right-content">
                <VLock
                  class="margin-small-left"
                  v-model="settings.lock.language_id"
                />
              </div>
            </template>
          </SmartSelector>
        </div>
        <div
          class="middle margin-medium-top flex-separate"
          v-if="selected"
        >
          <span
            class="separate-right"
            v-html="selected.english_name"
          />
          <VBtn
            color="primary"
            icon
            variant="tonal"
            @click="unset"
          >
            <IconTrash class="w-4 h-4" />
          </VBtn>
        </div>
      </fieldset>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useSettingStore } from '../../store'
import { Language } from '@/routes/endpoints'
import VLock from '@/components/ui/VLock/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import SmartSelector from '@/components/ui/SmartSelector'

const source = defineModel({
  type: Object,
  required: true
})

const settings = useSettingStore()

watch(
  () => source.value.language_id,
  (newVal, oldVal) => {
    if (newVal && newVal) {
      if (!oldVal || oldVal !== newVal) {
        Language.find(newVal).then(({ body }) => {
          selected.value = body
        })
      }
    }
  },
  { immediate: true }
)

watch(
  () => source.value.language_id,
  (newVal) => {
    if (!newVal) {
      selected.value = undefined
    }
  }
)

const selected = ref()

function setSelected(language) {
  source.value.isUnsaved = true
  source.value.language_id = language.id
  selected.value = language
}

function unset() {
  selected.value = undefined
  source.value.language_id = null
  source.value.isUnsaved = true
}
</script>
