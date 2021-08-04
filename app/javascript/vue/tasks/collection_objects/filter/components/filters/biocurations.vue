<template>
  <div>
    <h3>Biocurations</h3>
    <ul
      v-if="biocurations.length"
      class="no_bullets">
      <li
        v-for="item in biocurations"
        :key="item.id"
        class="margin-small-bottom">
        <label>
          <input
            type="checkbox"
            v-model="selectedBiocurations"
            :value="item.id">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
    <a
      v-else
      href="/tasks/controlled_vocabularies/biocuration/build_collection">Create new</a>
  </div>
</template>

<script>

import { ControlledVocabularyTerm } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    selectedBiocurations: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },
  data () {
    return {
      biocurations: []
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)

    this.selectedBiocurations = urlParams.biocuration_class_ids || []
    ControlledVocabularyTerm.where({ type: ['BiocurationClass'] }).then(response => { this.biocurations = response.body })
  }
}
</script>
