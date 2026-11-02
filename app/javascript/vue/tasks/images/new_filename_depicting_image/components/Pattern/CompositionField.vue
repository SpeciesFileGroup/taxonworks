<template>
  <div class="relative">
    <VBadge
      :class="[
        'composition-item',
        {
          'composition-item--optional': field.optional,
          'composition-item--selected': isSelected
        }
      ]"
      :color="ROLE_COLORS[field.role]"
      :title="`${ROLE_LABELS[field.role]}${field.optional ? ' (optional)' : ''}`"
    >
      <span class="font-bold">
        {{ ROLE_LABELS[field.role] }}{{ isRest ? '…' : '' }}
      </span>
      <VBtn
        small
        circle
        variant="ghost"
        title="Edit"
        @click.stop="store.openItem(field.id)"
      >
        <VIcon
          name="pencil"
          xx-small
        />
      </VBtn>
      <CompositionRemove @remove="emit('remove')" />
    </VBadge>
    <Popup
      v-if="isSelected"
      class="composition-popup padding-small"
      @close="store.closeItem()"
    >
      <PatternProperties
        :item="field"
        :index="index"
      />
    </Popup>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../../store/store'
import { ROLE_COLORS, ROLE_LABELS } from '../../constants'
import { isRestField } from '../../utils/pattern'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import Popup from '@/components/ui/Popup/Popup.vue'
import CompositionRemove from './CompositionRemove.vue'
import PatternProperties from './PatternProperties.vue'

const props = defineProps({
  field: {
    type: Object,
    required: true
  },

  index: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['remove'])

const store = useStore()

const isSelected = computed(() => store.selectedId === props.field.id)
const isRest = computed(() => isRestField(store.composition, props.index))
</script>
