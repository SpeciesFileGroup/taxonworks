<template>
  <div class="three_quarter_width margin-medium-left">
    <spinner-component v-if="isLoading"/>
    <table class="full_width">
      <thead>
        <tr>
          <th @click="sortTable('name')">Name</th>
          <th @click="sortTable('definition')">Definition</th>
          <th @click="sortTable('count')">Uses</th>
          <th>Show</th>
          <th>Edit</th>
          <th>Pin</th>
          <th>Destroy</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in list"
          :key="item.id">
          <td
            class="line-nowrap"
            v-html="item.object_tag"></td>
          <td>{{ item.definition }}</td>
          <td>{{ item.count }}</td>
          <td>
            <a :href="`/controlled_vocabulary_terms/${item.id}`">Show</a>
          </td>
          <td>
            <span
              class="button button-circle btn-edit"
              @click="editItem(index)"/>
          </td>
          <td>
            <pin-component
              class="button button-circle"
              v-if="item.id"
              :object-id="item.id"
              :section="`${item.type}s`"
              type="ControlledVocabularyTerm"
            />
          </td>
          <td>
            <span
              class="button button-circle btn-delete"
              @click="removeCTV(index)"/>
          </td>
        </tr>
      </tbody>
    </table>
    <span>{{ list.length }} records.</span>
  </div>
</template>

<script>

import { GetControlledVocabularyTerms, DestroyControlledVocabularyTerm } from '../request/resources'
import SpinnerComponent from 'components/spinner.vue'
import PinComponent from 'components/pin.vue'

export default {
  components: {
    SpinnerComponent,
    PinComponent
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
      isLoading: false,
      ascending: false
    }
  },
  watch: {
    type: {
      handler(newVal, oldVal) {
        if (newVal !== oldVal) {
          this.isLoading = true
          GetControlledVocabularyTerms({ 'type[]': newVal }).then(response => {
            this.list = response.body
            this.isLoading = false
          })
        }
      },
      immediate: true
    }
  },
  methods: {
    editItem (index) {
      this.$emit('edit', this.list[index])
    },
    removeCTV (index) {
      if (window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.isLoading = true
        DestroyControlledVocabularyTerm(this.list[index].id).then(response => {
          this.list.splice(index, 1)
          this.isLoading = false
        })
      }
    },
    addCTV (item) {
      const index = this.list.findIndex(ctv => { return ctv.id === item.id })

      if (index > -1) {
        this.$set(this.list, index, item)
      } else {
        this.list.unshift(item)
      }
    },
    sortTable (sortProperty) {
      this.list.sort((a, b) => {
        if (a[sortProperty] < b[sortProperty]) {
          return (this.ascending ? -1 : 1)
        }
        if (a[sortProperty] > b[sortProperty]) {
          return (this.ascending ? 1 : -1)
        }
        return 0
      })
      this.ascending = !this.ascending
    }
  }
}
</script>
