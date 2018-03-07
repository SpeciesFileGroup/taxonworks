<template>
<div>
  <h2>Type</h2>
  <ul>
    <li
      v-for="(label, key) in types"
      :key="key"> {{ label }}
    </li>
  </ul>
</div>
</template>
<script>
  export default {
    data() {
      return {
        types: {
          'Descriptor::Continuous': '',
          'Descriptor::Gene': 'Gene',
          'Descriptor::PresenceAbsence': 'Presence absence', 
          'Descriptor::Qualitative': 'Qualitative (e.g. a phylogenetic character, or telegraphic description)',
          'Descriptor::Sample': 'Sample ( a statistical summary, n, min, max, std, etc.)',
          'Descriptor::Working': '',
        }
      }
    }
  }
</script>