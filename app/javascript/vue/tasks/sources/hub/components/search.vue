<template>
  <div>
    <h3 class="title-section">Search</h3>
    <div class="flex-wrap-row middle">
      <div class="panel content card-new">
        <autocomplete
          url="/sources/autocomplete"
          param="term"
          label="label_html"
          @getItem="loadSource"
          placeholder="Select a source"/>

      </div>
      <a
        v-for="task in tasks"
        class="panel content separate-right separate-bottom card-new"
        tabindex="0"
        data-turbolinks="false" 
        target="blank"
        :href="task.url">
        <div class="task-name">{{ task.label }}</div>
      </a>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  data() {
    return {
      tasks: [
      {
        label: 'Alphabetical list of source authors',
        url: '/tasks/people/author'
      }]
    }
  },
  methods: {
    loadSource(source) {
      window.open(`/sources/${source.id}`)
    }
  }
}
</script>



<style lang="scss" scoped>
  /deep/ .vue-autocomplete-input {
    width: 100%;
  }
  .card-new {
    width: 250px;
    margin-bottom: 8px;
    margin-right: 8px;
    text-decoration: none;
    align-items: middle;
  }

  .task-name {
    font-size: 16px;
  }

  .task-description {
    color: #000000;
  }

</style>