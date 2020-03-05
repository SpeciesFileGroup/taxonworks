<template>
  <div class="full_width margin-medium-left">
    <spinner-component v-if="isLoading"/>
    <table>
      <thead>
        <tr>
          <th>Word</th>
          <th>Definition</th>
          <th>Uses</th>
          <th>Edit</th>
          <th>Destroy</th>
          <th>Browse</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, index) in list">
          <td
            class="line-nowrap"
            v-html="item.object_tag"></td>
          <td>{{ item.definition }}</td>
          <td>{{ item.count }}</td>
          <td>
            <span
              class="button button-circle btn-edit"
              @click="editItem(index)"/>
          </td>
          <td>
            <span
              class="button button-circle btn-delete"
              @click="removeCTV(index)"/>
          </td>
          <td><radial-navigation :global-id="item.global_id"/></td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import { GetControlledVocabularyTerms, DestroyControlledVocabularyTerm } from '../request/resources'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import SpinnerComponent from 'components/spinner.vue'

export default {
  components: {
    RadialNavigation,
    SpinnerComponent
  },
  props: {
    type: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      list: [],
      isLoading: false
    }
  },
  watch: {
    type: {
      handler(newVal, oldVal) {
        if(newVal != oldVal) {
          this.isLoading = true
          GetControlledVocabularyTerms({ 'type[]': newVal}).then(response => {
            this.list = response.body,
            this.isLoading = false
          })
        }
      },
      immediate: true
    }
  },
  methods: {
    editItem(index) {
      this.$emit('edit', this.list[index])
    },
    removeCTV(index) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.isLoading = true
        DestroyControlledVocabularyTerm(this.list[index].id).then(response => {
          this.list.splice(index, 1)
          this.isLoading = false
        })
      }
    },
    addCTV (item) {
      const index = this.list.findIndex(ctv => { return ctv.id === item.id })

      if(index > -1) {
        this.$set(this.list, index, item)
      }
      else {
        this.list.unshift(item)
      }
    }
  }
}
</script>