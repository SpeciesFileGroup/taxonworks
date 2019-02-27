<template>
  <div>
    <h2>New</h2>
    <div class="flex-wrap-row">
      <a
        v-for="task in tasks"
        class="panel content card"
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
      }]
    }
  }
}
</script>

<style lang="scss" scoped>

  .card {
    width: 400px;
    margin-bottom: 8px;
    margin-left: 8px;
  }

  .task-name {
    font-size: 18px;
  }

  .task-description {
    color: #000000;
  }

</style>