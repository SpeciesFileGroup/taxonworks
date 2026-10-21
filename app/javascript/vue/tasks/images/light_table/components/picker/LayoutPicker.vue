<template>
  <div class="horizontal-left-content align-start gap-medium">
    <div class="panel content light-table-picker__new">
      <h3>New light table</h3>
      <LayoutForm @create="(composition) => emit('select', composition)" />
    </div>

    <div class="panel content full_width">
      <h3>Open a light table</h3>
      <VAutocomplete
        url="/compositions/autocomplete"
        param="term"
        label="label_html"
        placeholder="Search a light table..."
        :add-params="{ type: COMPOSITION_TYPE }"
        clear-after
        @select="({ id }) => emit('select', { id })"
      />

      <div
        v-if="quick.length"
        class="horizontal-left-content gap-small margin-medium-top"
      >
        <span>Pinned and recent:</span>
        <VBtn
          v-for="composition in quick"
          :key="composition.id"
          color="primary"
          variant="outline"
          @click="emit('select', composition)"
        >
          {{ composition.name }}
        </VBtn>
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
import { COMPOSITION_TYPE } from '../../constants'
import LayoutForm from './LayoutForm.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ButtonPin from '@/components/ui/Button/ButtonPin.vue'

const emit = defineEmits(['select'])

const compositions = ref([])
const quick = ref([])
const isLoading = ref(false)

function formatDate(date) {
  return new Date(date).toLocaleString()
}

function loadCompositions() {
  isLoading.value = true

  Promise.all([
    Composition.where({ type: COMPOSITION_TYPE, per: 100 }),
    Composition.selectOptions({ type: COMPOSITION_TYPE })
  ])
    .then(([{ body: list }, { body: options }]) => {
      compositions.value = list
      quick.value = options.quick
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
      quick.value = quick.value.filter((c) => c.id !== composition.id)
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
