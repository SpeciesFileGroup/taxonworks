<template>
<div>
  <h2>Type</h2>
  <ul class="no_bullets">
    <li
      v-for="(label, key) in types"
      :key="key">
      <label>
        <input type="radio" v-model="selection" :value="key" name="type-descriptor"/>
        {{ label }}
      </label>
    </li>
  </ul>
</div>
</template>
<script>
  export default {
    props: {
      value: {
        type: String,
      }
    },
    computed: {
      selection: {
        get() {
          return this.value
        },
        set(value) {
          this.$emit('input', value)
        }
      }
    },
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
    },
  }
</script>