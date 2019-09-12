<template>
  <div>
    <h3>Identifier range</h3>
    <label>Namespace (optional)</label>
    <autocomplete
      url="/namespaces/autocomplete"
      param="term"
      label="label">
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  }
}
</script>