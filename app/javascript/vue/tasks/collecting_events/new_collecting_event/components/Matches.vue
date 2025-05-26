<template>
  <div
    v-if="founded.length"
    class="matches-panel panel content"
  >
    <h3>Matches</h3>
    <VSpinner
      v-if="isSearching"
      legend="Searching..."
    />
    <DisplayList
      :list="founded"
      label="object_tag"
      :remove="false"
      edit
      @edit="(e) => emit('select', e)"
    />
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { CollectingEvent } from '@/routes/endpoints'
import DisplayList from '@/components/displayList.vue'
import VSpinner from '@/components/ui/VSpinner'

const DELAY = 1000

let timer = undefined

const props = defineProps({
  collectingEvent: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['select'])

const isSearching = ref(false)
const list = ref([])

const verbatimLabel = computed(() => props.collectingEvent.verbatim_label)

const founded = computed(() =>
  list.value.filter((item) => item.id !== props.collectingEvent.id)
)

function getRecent() {
  isSearching.value = true
  CollectingEvent.where({
    verbatim_label: verbatimLabel.value,
    per: 5
  })
    .then(({ body }) => {
      list.value = body
    })
    .finally(() => {
      isSearching.value = false
    })
}

watch(verbatimLabel, (newVal) => {
  clearTimeout(timer)
  if (newVal && newVal.length) {
    timer = setTimeout(() => {
      getRecent()
    }, DELAY)
  } else {
    list.value = []
  }
})
</script>
