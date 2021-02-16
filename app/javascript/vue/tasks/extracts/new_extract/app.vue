<template>
  <div>
    <h1>New extract</h1>
    <navbar-component>
      <div class="flex-separate middle">
        New
        <div class="horizontal-right-content">
          <button
            type="button"
            class="button normal-input button-submit margin-small-right">
            Save
          </button>
          <button
            type="button"
            class="button normal-input button-default margin-small-right">
            Recent
          </button>
          <button
            type="button"
            class="button normal-input button-default">
            New
          </button>
        </div>
      </div>
    </navbar-component>
    <origin-component/>
    <made-component/>
    <repository-component/>
  </div>
</template>

<script>

import NavbarComponent from 'components/navBar'
import OriginComponent from './components/Origin'
import MadeComponent from './components/Made'
import RepositoryComponent from './components/Repository'

export default {
  components: {
    NavbarComponent,
    OriginComponent,
    MadeComponent,
    RepositoryComponent
  }
}
</script>
