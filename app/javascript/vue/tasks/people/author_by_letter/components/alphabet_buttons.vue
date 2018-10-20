<template>
  <div>
    <table>
      <tr
        v-for="(row, index) in rows"
        :key="index">
        <td
          v-for="letter in row"
          :key="letter"
          :class="{ 'selected-letter': (letter == selected) }"
          @click="sendLetter(letter)">{{ letter }}
        </td>
      </tr>
    </table>
  </div>
</template>
<script>
  export default {
    data() {
      return {
        rows: {
          alphabet1: "ABCDEFGHIJKLM".split(""),
          alphabet2: "NOPQRSTUVWXYZ".split("")
        },
        selected: ''
      }
    },
    methods: {
      sendLetter(letter) {
        if(letter == this.selected) return
        this.setSelectedLetter(letter)
        this.$emit("keypress", letter);
      },
      setSelectedLetter(letter) {
        this.selected = letter
        let urlParams = new URLSearchParams(window.location.search)
        urlParams.set('letter', letter)
        history.pushState(null, null, `/tasks/people/author?${urlParams.toString()}`)
      }
    }
  }
</script>

<style scoped>
  .selected-letter {
    color: #FFF;
    background-color: #E3E8E3;
  }
</style>