<template>
  <div>
    <ul class="no_bullets context-menu">
      <li
        v-for="type in types"
        :key="type">
        <label>
          <checkbox-component
            :val="type" 
            v-model="selected"
          />
          {{ type }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import CheckboxComponent from './checkboxComponent'

export default {
  components: {
    CheckboxComponent
  },
  data () {
    return {
      types: ['RNA', 'AA', 'DNA'],
      selected: []
    }
  }
}
</script>
