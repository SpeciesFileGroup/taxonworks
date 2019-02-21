<template>
  <div>
    <spinner-component
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isLoading"
    />
    <h1>Otu browser</h1>
    <header-bar
      :otu="otu" />
  </div>
</template>

<script>

import HeaderBar from './components/HeaderBar'
import SpinnerComponent from 'components/spinner'

import { GetOtu } from './request/resources.js'

export default {
  components: {
    HeaderBar,
    SpinnerComponent
  },
  data() {
    return {
      isLoading: false,
      otu: undefined,
    }
  },
  mounted() {

    let otuId = location.pathname.split('/')[4]
      if (/^\d+$/.test(otuId)) {
        GetOtu(otuId).then(response => {
          this.otu = response.body
          this.isLoading = false
        })
      } else {
        this.isLoading = false
      }
  }
}
</script>