<template>
  <div>
    <h3>Biocurations</h3>
    <div>
      <div v-for="group in biocurationGroups">
        <label>{{ group.name }}</label>
        <br>
        <template
          v-for="item in group.list"
          :key="item.id">
          <button
            class="bottom normal-input biocuration-toggle-button"
            type="button"
            :class="{ 'button-default': !biocurations.includes(item.id) }"
            @click="toggleBiocuration(item)">{{ item.name }}
          </button>
        </template>
      </div>
    </div>
  </div>
</template>

<script>

import {
  ControlledVocabularyTerm,
  Tag
} from 'routes/endpoints'

export default {
  props: {
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    biocurations: {
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
      biocurationTypes: [],
      biocurationGroups: []
    }
  },

  async created () {
    this.biocurationTypes = (await ControlledVocabularyTerm.where({ type: ['BiocurationClass'] })).body
    this.biocurationGroups = (await ControlledVocabularyTerm.where({ type: ['BiocurationGroup'] })).body
    this.splitGroups()
  },

  methods: {
    toggleBiocuration (biocuration) {
      const index = this.biocurations.findIndex(id => id === biocuration.id)

      if (index > -1) {
        this.biocurations.splice(index, 1)
      } else {
        this.biocurations.push(biocuration.id)
      }
    },

    splitGroups () {
      this.biocurationGroups.forEach((item, index) => {
        Tag.where({ keyword_id: item.id }).then(response => {
          const list = this.biocurationTypes.filter(biocurationType => response.body.find(item => biocurationType.id === item.tag_object_id))
          this.biocurationGroups[index]['list'] = list
        })
      })
    }
  }
}
</script>

<style>
  .biocuration-toggle-button {
    min-width: 60px;
    border: 0px;
    margin-right: 6px;
    margin-bottom: 6px;
    border-top-left-radius: 14px;
    border-bottom-left-radius: 14px;
  }
</style>
