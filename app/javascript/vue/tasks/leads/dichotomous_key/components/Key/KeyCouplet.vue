<template>
  <ul :class="['ul-lead', !store.indentation && 'padding-remove-left']">
    <li>
      <template
        v-for="(lead, index) in node.children"
        :key="lead.id"
      >
        <KeyLead
          :lead="lead"
          :backLink="node.backLink"
          :class="[
            !store.indentation &&
              index == node.children.length - 1 &&
              'margin-medium-bottom'
          ]"
          @scroll:couplet="(target) => emit('scroll:couplet', target)"
        />
      </template>
      <KeyCouplet
        v-for="next in nextCouplets"
        :key="next.id"
        :node="next"
        @scroll:couplet="(target) => emit('scroll:couplet', target)"
      />
    </li>
  </ul>
</template>

<script setup>
import { computed } from 'vue'
import KeyLead from './KeyLead.vue'
import useSettingsStore from '../../store/settings.js'

const props = defineProps({
  node: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['scroll:couplet'])

const store = useSettingsStore()

const nextCouplets = computed(() =>
  props.node.children.map((l) => l.nextCouplet).filter(Boolean)
)
</script>

<style scoped>
.ul-lead {
  list-style: none;
}

.ul-lead:first-child {
  margin-left: 2rem;
  padding-left: 0px;
}
</style>
