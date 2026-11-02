<template>
  <div class="flex-col gap-xsmall">
    <div class="horizontal-left-content middle gap-small separator-represents">
      <span>
        Separator <b>{{ displaySeparator(separator.value) }}</b> represents
      </span>
      <VBtn
        color="primary"
        :variant="hasRepresents ? 'outline' : 'solid'"
        @click="setRepresents(undefined)"
      >
        Itself
      </VBtn>
      <VBtn
        color="primary"
        :variant="separator.represents === '' ? 'solid' : 'outline'"
        title="The separator is not part of the identifier"
        @click="setRepresents('')"
      >
        Nothing
      </VBtn>
      <VBtn
        v-for="delimiter in suggestions"
        :key="delimiter"
        color="primary"
        :variant="separator.represents === delimiter ? 'solid' : 'outline'"
        @click="setRepresents(delimiter)"
      >
        {{ displaySeparator(delimiter) }}
      </VBtn>
      <input
        type="text"
        placeholder="Other characters"
        :value="separator.represents || ''"
        @input="(e) => setRepresents(e.target.value || undefined)"
      />
      <VBtn
        circle
        color="primary"
        title="Remove separator"
        @click="store.removeIdentifierSeparator(fieldId, separator.id)"
      >
        <VIcon
          name="trash"
          x-small
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../../store/store'
import { displaySeparator } from '../../utils/pattern'
import { IDENTIFIER_DELIMITERS } from '../../constants'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  fieldId: {
    type: String,
    required: true
  },

  separator: {
    type: Object,
    required: true
  }
})

const store = useStore()

const hasRepresents = computed(
  () => typeof props.separator.represents === 'string'
)

const suggestions = computed(() =>
  IDENTIFIER_DELIMITERS.filter((d) => d !== props.separator.value)
)

function setRepresents(value) {
  store.setSeparatorRepresents(props.fieldId, props.separator.id, value)
}
</script>

<style scoped>
.separator-represents {
  flex-wrap: wrap;
}
</style>
