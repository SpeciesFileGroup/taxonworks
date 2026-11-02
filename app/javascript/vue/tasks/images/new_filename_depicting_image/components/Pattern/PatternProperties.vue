<template>
  <div class="flex-col gap-small pattern-properties">
    <div class="flex-separate middle gap-small">
      <span class="font-bold">{{ ROLE_LABELS[item.role] }}</span>
      <VBtn
        color="primary"
        @click="store.removeCompositionItem(index)"
      >
        Remove
      </VBtn>
    </div>
    <label class="horizontal-left-content middle gap-xsmall">
      Role
      <select
        :value="item.role"
        @change="(e) => store.setFieldRole(item.id, e.target.value)"
      >
        <option
          v-for="role in ROLES"
          :key="role"
          :value="role"
          :disabled="role !== item.role && store.isRoleUsed(role)"
        >
          {{ ROLE_LABELS[role] }}
        </option>
      </select>
    </label>
    <label
      v-if="item.role !== ROLE.Identifier"
      class="horizontal-left-content middle gap-xsmall"
      title="Filenames may or may not include this field"
    >
      <input
        type="checkbox"
        :checked="item.optional"
        @change="(e) => store.setFieldOptional(item.id, e.target.checked)"
      />
      Optional
    </label>
    <label
      v-if="isLast && !item.separators.length"
      class="horizontal-left-content middle gap-xsmall"
      title="This field takes the rest of the filename"
    >
      <input
        type="checkbox"
        :checked="item.rest"
        @change="(e) => store.setFieldRest(item.id, e.target.checked)"
      />
      Until the end of the filename
    </label>
    <label
      v-if="isTextRole"
      class="horizontal-left-content middle gap-xsmall"
      title="Replace underscores with spaces in this field"
    >
      <input
        type="checkbox"
        :checked="item.underscoresAsSpaces"
        @change="
          (e) => store.setFieldUnderscoresAsSpaces(item.id, e.target.checked)
        "
      />
      Underscores as spaces
    </label>

    <div
      v-if="item.role === ROLE.Identifier"
      class="flex-col gap-small"
    >
      <span>Separators inside the identifier</span>
      <SeparatorRepresents
        v-for="separator in item.separators"
        :key="separator.id"
        :field-id="item.id"
        :separator="separator"
      />
      <div class="relative">
        <VBtn
          color="primary"
          @click="showSeparators = true"
        >
          Add separator
        </VBtn>
        <Popup
          v-if="showSeparators"
          class="padding-small"
          @close="showSeparators = false"
        >
          <SeparatorPicker
            @select="
              (value) => {
                store.addIdentifierSeparator(item.id, value)
                showSeparators = false
              }
            "
          />
        </Popup>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from '../../store/store'
import { ROLE, ROLE_LABELS } from '../../constants'
import VBtn from '@/components/ui/VBtn/index.vue'
import Popup from '@/components/ui/Popup/Popup.vue'
import SeparatorPicker from './SeparatorPicker.vue'
import SeparatorRepresents from './SeparatorRepresents.vue'

const ROLES = [ROLE.Identifier, ROLE.Label, ROLE.Caption, ROLE.Ignore]

const props = defineProps({
  item: {
    type: Object,
    required: true
  },

  index: {
    type: Number,
    required: true
  }
})

const store = useStore()

const showSeparators = ref(false)

const isLast = computed(() => props.index === store.composition.length - 1)
const isTextRole = computed(() =>
  [ROLE.Label, ROLE.Caption].includes(props.item.role)
)
</script>

<style scoped>
.pattern-properties {
  min-width: 20rem;
  white-space: normal;
}
</style>
