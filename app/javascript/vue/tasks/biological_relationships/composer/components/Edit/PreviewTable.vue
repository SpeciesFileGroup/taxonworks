<template>
  <div>
    <table
      class="full_width"
      v-if="list.length">
      <thead>
        <tr>
          <th>
            {{ subjectString }}
            <br>
            Subject
          </th>
          <th>Relationship</th>
          <th>
            {{ objectString }}
            <br>
            Object
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id">
          <td v-html="item.subject.object_tag"></td>
          <td v-html="item.biological_relationship.object_tag"></td>
          <td v-html="item.object.object_tag"></td>
        </tr>
      </tbody>
    </table>
    <i v-else>None</i>
  </div>
</template>

<script>

import { BiologicalRelationship } from 'routes/endpoints'

export default {
  props: {
    biologicalRelationship: {
      type: Object,
      default: undefined
    },
    subjectString: {
      type: String,
      default: undefined
    },
    objectString: {
      type: String,
      default: undefined
    }
  },

  data () {
    return {
      list: []
    }
  },

  watch: {
    biologicalRelationship (newVal) {
      if (newVal) {
        BiologicalRelationship.find(newVal.id).then(response => {
          this.list = response.body
        })
      } else {
        this.list = []
      }
    }
  }
}
</script>
