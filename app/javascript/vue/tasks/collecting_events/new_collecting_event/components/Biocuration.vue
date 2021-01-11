<template>
  <div>
    <h3>Biocurations</h3>
    <div>
      <div v-for="group in biocurationGroups">
        <label>{{ group.name }}</label>
        <br>
        <template
          v-for="item in group.list">
          <button
            class="bottom normal-input biocuration-toggle-button"
            type="button"
            :key="item.id"
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
  GetBiocurationsTypes,
  GetBiocurationsGroupTypes,
  GetBiocurationsTags
} from '../request/resources'

export default {
  props: {
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    biocurations: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      biocurationTypes: [],
      biocurationGroups: []
    }
  },
  async mounted () {
    this.biocurationTypes = (await GetBiocurationsTypes()).body
    this.biocurationGroups = (await GetBiocurationsGroupTypes()).body
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
        GetBiocurationsTags(item.id).then(response => {
          const list = this.biocurationTypes.filter(biocurationType => response.body.find(item => biocurationType.id === item.tag_object_id))
          this.$set(this.biocurationGroups[index], 'list', list)
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
