<template>
  <div id="hub">
    <h1>Task - New source</h1>
    <div>
      <new-component/>
    </div>
    <recent-component/>
  </div>
</template>

<script>

import NewComponent from './components/new'
import TasksComponent from './components/tasks'
import RecentComponent from './components/recent'

export default {
  components: {
    NewComponent,
    TasksComponent,
    RecentComponent
  }
}
</script>