<template>
  <div>
    <h3>All tasks</h3>
    <div class="flex-wrap-row">
      <a
        v-for="task in tasks"
        class="panel content card"
        tabindex="0"
        data-turbolinks="false" 
        target="blank"
        :href="task.url">
        <div class="task-name">{{ task.name }}</div>
        <div class="task-description">{{ task.description }}</div>
      </a>
    </div>
  </div>
</template>

<script>

import { GetMetadata } from '../request/resources.js'

export default {
  data() {
    return {
      tasks: []
    }
  },
  mounted() {
    GetMetadata().then(response => {
      this.tasks = response.body
    })
  }
}
</script>

<style lang="scss" scoped>

  #task_carrousel {
    width: 900px;
  }

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
