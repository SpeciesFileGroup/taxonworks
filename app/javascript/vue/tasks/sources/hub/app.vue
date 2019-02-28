<template>
  <div>
    <h1>Task: Source hub</h1>
    <div>
      <new-component/>
    </div>
    <recent-component/>
  </div>
</template>

<script>

import NewComponent from './components/new'
import RecentComponent from './components/recent'

export default {
  components: {
    NewComponent,
    RecentComponent
  }
}
</script>