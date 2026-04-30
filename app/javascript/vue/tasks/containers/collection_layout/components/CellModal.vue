<template>
  <VModal
    :container-style="{ width: occupant ? '860px' : '520px' }"
    @close="$emit('close')"
  >
    <template #header>
      <h3>Cell ({{ cell.col }}, {{ cell.row }})</h3>
    </template>
    <template #body>
      <div :class="['flex-row gap-medium align-start']">
        <!-- Left column: placement -->
        <div class="modal-col-placement">
          <div
            v-if="occupant"
            class="flex-row gap-small middle"
          >
            <strong>Current occupant:</strong> {{ occupant.name }}
            <span class="feedback feedback-thin feedback-secondary">{{
              occupant.type
            }}</span>
            <VBtn
              color="destroy"
              circle
              @click="$emit('unplace', occupant)"
            >
              <VIcon
                name="undo"
                x-small
                class="icon-unplace"
              />
            </VBtn>
          </div>

          <div v-if="unplacedChildren.length">
            <h4>Unplaced children</h4>
            <ul class="unplaced-list">
              <li
                v-for="item in unplacedChildren"
                :key="item.container_item_id"
                class="unplaced-item"
                @click="$emit('place', item)"
              >
                <span class="container-type-badge">{{
                  displayType(item.type)
                }}</span>
                {{ item.name }}
              </li>
            </ul>
          </div>
          <div
            v-else
            class="subtle"
          >
            <i>No unplaced children.</i>
          </div>

          <hr class="divisor full_width" />

          <h4>Find and place a container</h4>
          <div class="horizontal-left-content gap-small">
            <VAutocomplete
              url="/containers/autocomplete"
              placeholder="Find a container…"
              param="term"
              label="label"
              @get-item="onAutocomplete"
            />
          </div>

          <span
            v-if="placeError"
            class="feedback-warning"
            >{{ placeError }}</span
          >
        </div>

        <!-- Right column: edit occupant attributes -->
        <OccupantEditPanel
          v-if="occupant"
          :occupant="occupant"
          @updated="$emit('occupant-updated', $event)"
        />
      </div>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import OccupantEditPanel from './OccupantEditPanel.vue'
import { displayType } from '../utils/containerType'

const props = defineProps({
  cell: {
    type: Object,
    required: true
  },
  occupant: {
    type: Object,
    default: null
  },
  unplacedChildren: {
    type: Array,
    default: () => []
  },
  placeError: {
    type: String,
    default: ''
  }
})

const emit = defineEmits([
  'close',
  'place',
  'unplace',
  'autocomplete-pick',
  'occupant-updated'
])

function onAutocomplete(container) {
  emit('autocomplete-pick', { container, cell: props.cell })
}
</script>

<style scoped>
.modal-col-placement {
  flex: 1 1 0;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75em;
}

.unplaced-list {
  list-style: none;
  margin: 0;
  padding: 0;
  max-height: 200px;
  overflow-y: auto;
}

.unplaced-item {
  padding: 4px 6px;
  border-radius: 3px;
  cursor: pointer;
  font-size: 0.9em;
}

.unplaced-item:hover {
  background: var(--bg-color);
}

.container-type-badge {
  background: #e8e8e8;
  border-radius: 3px;
  padding: 0 4px;
  font-size: 0.8em;
  margin-right: 4px;
  color: #555;
}
</style>
