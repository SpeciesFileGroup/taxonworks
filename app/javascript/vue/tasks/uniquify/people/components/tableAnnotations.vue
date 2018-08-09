<template>
  <div v-if="annotationLists.length">
    <h3>{{ title }}</h3> 
    <table>
      <tbody>
        <tr
          v-for="(item, index) in annotationLists"
          class="contextMenuCells"
          :class="{ even: (index % 2 == 0) }">
          <td class="column-property">{{ item.type }}</td>
          <td
            class="column-value"
            v-html="item.object_tag"/>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
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
  data() {
    return {
      annotationLists: []
    }
  },
  watch: {
    person(newVal) {
      if(newVal != undefined && Object.keys(newVal).length) {
        this.getAnnotations(newVal.global_id)
      }
      else {
        this.annotationLists = []
      }
    }
  },
  methods: {
    getAnnotations(globalId) {
      let that = this
      this.$http.get(`/annotations/${encodeURIComponent(globalId)}/metadata`).then(response => {
        Object.keys(response.body.endpoints).forEach((endpoint, index) => {
          if (response.body.endpoints[endpoint].total > 0) {
            this.$http.get(`${response.body.url}/${endpoint}.json`).then(response => {
              that.annotationLists = that.annotationLists.concat(response.body)
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
    min-width: 500px;
  }
</style>
