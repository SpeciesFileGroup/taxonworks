<template>
  <section
    :class="['specification-section', { 'section-disabled': !building }]"
  >
    <h3>Add rooms, cabinets &amp; drawers</h3>
    <fieldset :disabled="!building">
      <div class="horizontal-left-content gap-medium flex-wrap align-end">
        <label>
          Rooms
          <input
            v-model.number="roomCount"
            type="number"
            min="1"
            class="w-auto"
          />
        </label>

        <label>
          Cabinets per room
          <input
            v-model.number="cabinetCount"
            type="number"
            min="1"
            class="w-auto"
          />
        </label>

        <label>
          Drawer type
          <select v-model="drawerType">
            <option
              v-for="dt in drawerTypeOptions"
              :key="dt.key"
              :value="dt.key"
            >
              {{ dt.label }}
            </option>
          </select>
        </label>

        <label>
          Cabinet size x
          <input
            v-model.number="cabinetSizeX"
            type="number"
            min="1"
            placeholder="none"
            class="w-auto"
          />
        </label>

        <label>
          Cabinet size y
          <input
            v-model.number="cabinetSizeY"
            type="number"
            min="1"
            placeholder="none"
            class="w-auto"
          />
        </label>

        <label>
          Cabinet size z
          <input
            v-model.number="cabinetSizeZ"
            type="number"
            min="1"
            placeholder="none"
            class="w-auto"
          />
        </label>

        <label>
          Drawers per cabinet
          <input
            v-model.number="drawerCount"
            type="number"
            min="1"
            :max="maxDrawers ?? undefined"
            class="w-auto"
          />
        </label>

        <label>
          % empty
          <input
            v-model.number="defaultPercentEmpty"
            type="number"
            min="0"
            max="100"
            step="any"
            placeholder="none"
            class="w-auto"
          />
        </label>

        <label>
          % earmarked
          <input
            v-model.number="defaultPercentEarmarked"
            type="number"
            min="0"
            max="100"
            step="any"
            placeholder="none"
            class="w-auto"
          />
        </label>

        <VBtn
          color="create"
          medium
          :disabled="!scaffoldValid || scaffolding"
          @click="addRooms"
        >
          {{ scaffolding ? 'Adding…' : 'Add' }}
        </VBtn>
      </div>

      <div class="text-xs subtle gap-medium horizontal-left-content flex-wrap">
        <em v-if="cabinetDimensions">
          {{ selectedDrawerType.label }}:
          {{ cabinetDimensions.x }}&thinsp;×&thinsp;{{
            cabinetDimensions.y
          }}
          grid (max {{ maxDrawers }} drawers per cabinet)
        </em>
        <em class="subtle">{{ previewText }}</em>
      </div>

      <span
        v-if="error"
        class="feedback-warning"
        >{{ error }}</span
      >
    </fieldset>
  </section>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import { Container } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  building: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['scaffolded'])

const drawerTypeOptions = ref([])

const drawerType = ref('Container::Drawer')
const cabinetSizeX = ref(null)
const cabinetSizeY = ref(null)
const cabinetSizeZ = ref(null)
const roomCount = ref(1)
const cabinetCount = ref(1)
const drawerCount = ref(1)
const defaultPercentEmpty = ref(null)
const defaultPercentEarmarked = ref(null)
const scaffolding = ref(false)
const error = ref('')

const selectedDrawerType = computed(() =>
  drawerTypeOptions.value.find((t) => t.key === drawerType.value)
)

const cabinetDimensions = computed(
  () => selectedDrawerType.value?.dimensions ?? null
)

const maxDrawers = computed(() => {
  const d = cabinetDimensions.value
  return d ? d.x * d.y * d.z : null
})

watch(maxDrawers, (max) => {
  if (max !== null && drawerCount.value > max) {
    drawerCount.value = max
  }
})

const previewText = computed(() => {
  const r = roomCount.value || 0
  const c = cabinetCount.value || 0
  const d = drawerCount.value || 0
  return `${r} room(s) × ${c} cabinet(s) × ${d} drawer(s) = ${r * c * d} drawers total`
})

const scaffoldValid = computed(
  () =>
    props.building &&
    roomCount.value > 0 &&
    cabinetCount.value > 0 &&
    drawerCount.value > 0
)

onMounted(async () => {
  const { body } = await Container.types()
  drawerTypeOptions.value = (body || [])
    .filter((t) => t.type && t.type.startsWith('Container::Drawer'))
    .map((t) => ({
      key: t.type,
      label: t.name || t.type.split('::').pop(),
      dimensions: t.dimensions || null
    }))
    .sort((a, b) => {
      if (a.key === 'Container::Drawer') return -1
      if (b.key === 'Container::Drawer') return 1
      return a.label.localeCompare(b.label)
    })
})

async function addRooms() {
  error.value = ''
  scaffolding.value = true

  const payload = {
    building_id: props.building.id,
    drawer_type: drawerType.value || 'Container::Drawer',
    rooms: roomCount.value,
    cabinets: cabinetCount.value,
    drawers: drawerCount.value
  }

  if (cabinetSizeX.value !== null && cabinetSizeX.value !== '')
    payload.cabinet_size_x = cabinetSizeX.value
  if (cabinetSizeY.value !== null && cabinetSizeY.value !== '')
    payload.cabinet_size_y = cabinetSizeY.value
  if (cabinetSizeZ.value !== null && cabinetSizeZ.value !== '')
    payload.cabinet_size_z = cabinetSizeZ.value

  if (defaultPercentEmpty.value !== null && defaultPercentEmpty.value !== '')
    payload.asserted_percent_empty = defaultPercentEmpty.value
  if (
    defaultPercentEarmarked.value !== null &&
    defaultPercentEarmarked.value !== ''
  )
    payload.asserted_percent_earmarked = defaultPercentEarmarked.value

  let body
  try {
    ;({ body } = await AjaxCall(
      'post',
      '/tasks/containers/collection_layout/scaffold.json',
      payload
    ))
  } catch (err) {
    scaffolding.value = false
    const errors = err?.response?.body
    error.value = errors
      ? Object.values(errors).flat().join(', ')
      : 'Failed to add containers.'
    return
  }

  scaffolding.value = false

  if (body?.created_rooms !== undefined) {
    emit('scaffolded', body)
  } else {
    error.value = body?.error || 'Failed to add containers.'
  }
}
</script>

<style scoped>
.section-disabled {
  opacity: 0.45;
  pointer-events: none;
}

label {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

input,
select {
  width: 100%;
  max-width: 100%;
}
</style>
