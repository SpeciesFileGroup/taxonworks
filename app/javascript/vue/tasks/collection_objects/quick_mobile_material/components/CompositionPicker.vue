<template>
  <fieldset class="fieldset">
    <legend>Find or create a table</legend>
    <div class="horizontal-left-content middle gap-small">
      <VAutocomplete
        class="full_width"
        url="/compositions/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a table..."
        :add-params="{ type: LAYOUT_TASK }"
        clear-after
        @select="({ id }) => emit('select', { id })"
      />
      <ButtonPinned
        section="Compositions"
        type="Composition"
        @get-id="(id) => emit('select', { id })"
      />
    </div>
    <div class="horizontal-left-content middle gap-small margin-medium-top">
      <input
        v-model="name"
        type="text"
        class="full_width"
        placeholder="Name of a new table"
        @keyup.enter="create"
      />
      <VBtn
        color="create"
        medium
        :disabled="!name.trim()"
        @click="create"
      >
        Create
      </VBtn>
    </div>
  </fieldset>
</template>

<script setup>
import { ref } from 'vue'
import { LAYOUT_TASK } from '@/constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import ButtonPinned from '@/components/ui/Button/ButtonPinned.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['select', 'create'])

const name = ref('')

function create() {
  if (!name.value.trim()) return

  emit('create', name.value.trim())
  name.value = ''
}
</script>
