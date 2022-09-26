<template>
  <div>
    <table
      class="full_width"
      v-if="list.length"
    >
      <thead>
        <tr>
          <th>
            Biological assocations
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
        >
          <td v-html="item.object_tag" />
        </tr>
      </tbody>
    </table>
    <i v-else>None</i>
  </div>
</template>

<script>

import { BiologicalAssociation } from 'routes/endpoints'
import { extend } from '../constants/extend.js'

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
        BiologicalAssociation.where({
          biological_relationship_id: newVal.id,
          per: 10,
          extend: [...extend, 'bioloical_relationship']
        }).then(response => {
          this.list = response.body
        })
      } else {
        this.list = []
      }
    }
  }
}
</script>
