<template>
  <div>
    <div v-if="navList">
      <h3>Current</h3>
      <div class="flex-separate middle">
        {{ navList.current_otu.object_label }}
        <div class="horizontal-left-content">
          <otu-radial :globalId="navList.current_otu.global_id"/>
          <radial-annotator :globalId="navList.current_otu.global_id"/>
          <radial-object :globalId="navList.current_otu.global_id"/>
        </div>
      </div>
      <template v-if="navList.parent_otus.length">
        <h4>Parent</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.parent_otus"
            :key="item.id">
            <a :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${item.id}`"> {{ item.object_label }}</a>
          </li>
        </ul>
      </template>
      <template v-if="navList.previous_otus.length">
        <h4>Previous</h4>
        <ul class="no_bullets">
          <li 
            v-for="item in navList.previous_otus"
            :key="item.id">
            <a :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${item.id}`"> {{ item.object_label }}</a>
          </li>
        </ul>
      </template>
      <template v-if="navList.next_otus.length">
        <h4>Next</h4>
        <ul class="no_bullets">
          <li
            v-for="item in navList.next_otus"
            :key="item.id">
            <a :href="`/tasks/otus/browse_asserted_distributions/index?otu_id=${item.id}`"> {{ item.object_label }}</a>
          </li>
        </ul>
      </template>
    </div>
  </div>
</template>

<script>

import { Otu } from 'routes/endpoints'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import OtuRadial from 'components/radials/object/radial'

export default {
  components: {
    RadialAnnotator,
    RadialObject,
    OtuRadial
  },
  props: {
    otuId: {
      type: [String, Number],
      default: undefined
    }
  },
  data () {
    return {
      navList: undefined
    }
  },
  watch: {
    otuId(newVal) {
      if(newVal) {
        this.loadNav(newVal)
      }
      else {
        this.navList = undefined
      }
    }
  },
  methods: {
    loadNav(id) {
      Otu.navigation(id).then(response => {
        this.navList = response.body
      })
    }
  }
}
</script>

<style>

</style>