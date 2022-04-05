<template>
  <div v-if="annotationLists.length">
    <h3>{{ title }}</h3> 
    <table>
      <tbody>
        <tr
          v-for="(item, index) in annotationLists"
          class="contextMenuCells"
          :class="{ even: (index % 2 == 0) }">
          <td
            class="column-value"
            v-html="item.object_tag"/>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>

import AjaxCall from 'helpers/ajaxCall'
import { Annotation } from 'routes/endpoints'

export default {
  props: {
    person: {
      type: Object,
      required: true
    },

    title: {
      type: String,
      required: true
    }
  },

  data () {
    return {
      annotationLists: []
    }
  },

  watch: {
    person: {
      handler (newVal) {
        if (newVal?.global_id) {
          this.getAnnotations(newVal.global_id)
        } else {
          this.annotationLists = []
        }
      },
      deep: true
    }
  },

  methods: {
    getAnnotations (globalId) {
      this.annotationLists = []

      Annotation.metadata(globalId).then(({ body }) => {
        const endpoints = Object.entries(body.endpoints)

        endpoints.forEach(([endpoint, obj], index) => {
          if (obj.total > 0) {
            AjaxCall('get', `${body.url}/${endpoint}.json`).then(response => {
              this.annotationLists = this.annotationLists.concat(response.body)
            })
          }
        })
      })
    }
  }
}
</script>
<style scoped>
  .column-property {
    min-width: 100px;
  }
  .column-value {
    min-width: 600px;
  }
</style>
