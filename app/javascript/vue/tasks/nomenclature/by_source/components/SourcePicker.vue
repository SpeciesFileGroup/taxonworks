<template>
  <div class="horizontal-left-content">
    <autocomplete
      url="/sources/autocomplete"
      min="2"
      param="term"
      label="label"
      clear-after
      placeholder="Search for a Source"
      @get-item="store.dispatch(ActionNames.LoadSource, $event.id)"
    />
    <default-source
      class="margin-small-left"
      type="Source"
      section="Sources"
      @get-id="store.dispatch(ActionNames.LoadSource, $event)"
    />
  </div>
</template>

<script setup>
import Autocomplete from 'components/ui/Autocomplete';
import DefaultSource from 'components/getDefaultPin'
import { useStore } from 'vuex';

const store = useStore()
</script>