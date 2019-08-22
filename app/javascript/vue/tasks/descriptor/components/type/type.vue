<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Type</h3>
    </div>
    <div class="body">
      <ul class="no_bullets">
        <li
          v-for="(label, key) in types"
          :key="key">
          <label>
            <input
              :disabled="descriptorId"
              type="radio"
              v-model="selection"
              :value="key"
              name="type-descriptor"/>
            {{ label }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>
<script>
  export default {
    props: {
      value: {
        type: String,
      },
      descriptorId: {
        default: undefined
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
          'Descriptor::Qualitative': 'Qualitative (e.g. a phylogenetic character, or telegraphic description)',
          'Descriptor::PresenceAbsence': 'Presence absence', 
          'Descriptor::Continuous': 'Quantitative (i.e continuous, e.g. a measurement)',
          'Descriptor::Sample': 'Sample ( a statistical summary, n, min, max, std, etc.)',
          'Descriptor::Gene': 'Gene',
          'Descriptor::Working': 'Free text',
          'Descriptor::Media': 'Media',
        }
      }
    },
  }
</script>