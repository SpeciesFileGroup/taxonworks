<template>
  <div class="flex-row gap-small">
    <VRecent />
    <VAutocomplete
      url="/sources/autocomplete"
      param="term"
      placeholder="Search a source..."
      label="label_html"
      clear-after
      @get-item="store.dispatch(ActionNames.LoadSource, $event.id)"
    />
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { ActionNames } from '../store/actions/actions'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VRecent from './recent'

const store = useStore()
</script>
