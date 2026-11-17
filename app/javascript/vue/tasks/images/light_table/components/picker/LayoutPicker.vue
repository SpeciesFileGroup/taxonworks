<template>
  <div>
    <div class="horizontal-left-content middle gap-small">
      <VAutocomplete
        class="full_width"
        url="/compositions/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a light table..."
        :add-params="{ type: LAYOUT_LIGHT_TABLE }"
        clear-after
        @select="({ id }) => emit('select', { id })"
      />
      <ButtonPinned
        section="Compositions"
        type="Composition"
        @get-id="(id) => emit('select', { id })"
      />
    </div>

    <VSpinner v-if="isLoading" />
    <p v-else-if="!compositions.length">No light tables yet.</p>
    <table
      v-else
      class="table-striped full_width margin-medium-top"
    >
      <thead>
        <tr>
          <th>Name</th>
          <th>Description</th>
          <th>Updated</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="composition in compositions"
          :key="composition.id"
        >
          <td>{{ composition.name }}</td>
          <td>{{ composition.description }}</td>
          <td>{{ formatDate(composition.updated_at) }}</td>
          <td>
            <div class="horizontal-right-content gap-small">
              <VBtn
                circle
                color="primary"
                title="Edit light table"
                @click="emit('select', composition)"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
              <ButtonPin
                :object-id="composition.id"
                type="Composition"
              />
              <VBtn
                circle
                color="destroy"
                title="Destroy light table"
                @click="destroyComposition(composition)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { Composition } from '@/routes/endpoints'
import { LAYOUT_LIGHT_TABLE } from '@/constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import ButtonPinned from '@/components/ui/Button/ButtonPinned.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ButtonPin from '@/components/ui/Button/ButtonPin.vue'

const emit = defineEmits(['select', 'destroyed'])

const compositions = ref([])
const isLoading = ref(false)

function formatDate(date) {
  return new Date(date).toLocaleString()
}

function loadCompositions() {
  isLoading.value = true

  Composition.where({ type: LAYOUT_LIGHT_TABLE, per: 100 })
    .then(({ body }) => {
      compositions.value = body
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}

function destroyComposition(composition) {
  if (
    !window.confirm(
      `Destroy "${composition.name}" and everything placed on it? This can not be undone.`
    )
  ) {
    return
  }

  Composition.destroy(composition.id)
    .then(() => {
      compositions.value = compositions.value.filter(
        (c) => c.id !== composition.id
      )
      emit('destroyed', composition.id)
      TW.workbench.alert.create(
        'Light table was successfully destroyed.',
        'notice'
      )
    })
    .catch(() => {})
}

onBeforeMount(loadCompositions)
</script>

