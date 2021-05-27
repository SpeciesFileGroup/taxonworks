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
        target="_self"
        :href="task.url">
        <div class="task-name">{{ task.label }}</div>
      </a>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'

export default {
  components: {
    Autocomplete
  },
  data () {
    return {
      tasks: [
        {
          label: 'Filter sources',
          url: '/tasks/sources/filter'
        }
      ]
    }
  },
  mounted () {
    const date = new Date()
    const userId = document.querySelector('[data-current-user-id]').getAttribute('data-current-user-id')
    const today = date.toISOString().split('T')[0]
    date.setDate(date.getDate() - 14)
    const twoWeeksAgo = date.toISOString().split('T')[0]

    this.tasks.push(
      {
        label: 'My recent sources',
        url: `/tasks/sources/filter?in_project=true&user_id=${userId}&user_target=updated&user_date_start=${twoWeeksAgo}&user_date_end=${today}&per=500&page=1`
      }
    )
    this.tasks.push(
      {
        label: 'Alphabetical list of source authors',
        url: '/tasks/people/author'
      },
    )
  },
  methods: {
    loadSource (source) {
      window.open(`/sources/${source.id}`, '_self')
    }
  }
}
</script>

<style lang="scss" scoped>
  ::v-deep .vue-autocomplete-input {
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