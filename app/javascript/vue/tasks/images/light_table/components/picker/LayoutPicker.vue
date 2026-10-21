<template>
  <div class="horizontal-left-content align-start gap-medium">
    <div class="panel content light-table-picker__new">
      <h3>New light table</h3>
      <LayoutForm @create="(composition) => emit('select', composition)" />
    </div>

    <div class="panel content full_width">
      <h3>Open a light table</h3>
      <SmartSelector
        ref="smartSelectorRef"
        model="compositions"
        :params="{ type: LAYOUT_LIGHT_TABLE }"
        :autocomplete-params="{ type: LAYOUT_LIGHT_TABLE }"
        pin-section="Compositions"
        pin-type="Composition"
        placeholder="Search a light table..."
        @selected="(composition) => emit('select', composition)"
      />

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
            <td>
              <a
                href="#"
                @click.prevent="emit('select', composition)"
              >{{
                composition.name
              }}</a>
            </td>
            <td>{{ composition.description }}</td>
            <td>{{ formatDate(composition.updated_at) }}</td>
            <td>
              <div class="horizontal-right-content gap-small">
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
  </div>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import { Composition } from '@/routes/endpoints'
import { LAYOUT_LIGHT_TABLE } from '@/constants'
import LayoutForm from './LayoutForm.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ButtonPin from '@/components/ui/Button/ButtonPin.vue'

const emit = defineEmits(['select'])

const compositions = ref([])
const smartSelectorRef = ref(null)
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
      smartSelectorRef.value?.refresh(true)
      TW.workbench.alert.create(
        'Light table was successfully destroyed.',
        'notice'
      )
    })
    .catch(() => {})
}

onBeforeMount(loadCompositions)
</script>

<style scoped>
.light-table-picker__new {
  min-width: 320px;
}
</style>
