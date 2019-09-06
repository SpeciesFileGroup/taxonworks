<template>
  <div>
    <h3>Otu</h3>
    <label>
      <input type="checkbox"/> All/Terminal
    </label>
    <label>
      <input type="checkbox"> 
      Linked to valid only
    </label>
  </div>
</template>

<script>

//import SwitchButton from 'components/forms/switchSlider.vue'

export default {
  components: {
    //SwitchButton
  },
  data () {
    return {
      all: false,
      valid: false
    }
  }
}
</script>
