<template>
  <div>
    <h3 class="title-section">New</h3>
    <div class="flex-wrap-row">
      <a
        v-for="task in tasks"
        class="panel content separate-right separate-bottom card-new"
        tabindex="0"
        data-turbolinks="false" 
        target="blank"
        :href="task.url">
        <div>
          <div class="task-name">{{ task.label }}</div>
        </div>
      </a>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      tasks: [
      {
        label: 'New source',
        url: '/sources/new'  
      },
      {
        label: 'New source from Bibtex',
        url: '/tasks/sources/individual_bibtex_source/index'
      },
      {
        label: 'New source from citation',
        url: '/tasks/bibliography/verbatim_reference/new'
      },
      {
        label: 'Batch load',
        url: '/sources/batch_load'
      }]
    }
  }
}
</script>

<style lang="scss" scoped>

  .card-new {
    width: 250px;
    margin-bottom: 8px;
    margin-right: 8px;
    text-decoration: none;
  }

  .task-name {
    font-size: 16px;
  }

  .task-description {
    color: #000000;
  }

</style>