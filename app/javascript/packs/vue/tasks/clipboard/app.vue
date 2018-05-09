<template>
  <div id="vue-clipboard-app">
    <button
      type="button"
      @click="CreateTest">
      CreateTest
    </button>
    <template v-for="(clip, index) in clipboard">
      <div>
        <span>Ctrl + {{ index }}</span>
        <textarea v-model="clipboard[index]"/>
      </div>
    </template>
  </div>
</template>
<script>

  import Spinner from '../../components/spinner.vue'
  import { GetClipboard, UpdateClipboard } from './request/resources'

  import KeyPress from './helpers/checkKey'

  export default {
    components: {
      Spinner
    },
    computed: {
    },
    data() {
      return {
        clipboard: [],
        data: 'Hello'
      }
    },
    mounted() {
      document.addEventListener("keydown", this.KeyPress);

    },
    destroy() {
      $(document).off("keydown");
    },
    methods: {
      CreateTest() {
        UpdateClipboard({ '1': 'text' }).then(response => {
          GetClipboard().then(response => {
            this.clipboard = response.clipboard
          })
        })
      },
      KeyPress(e) {
      let evtobj = window.event? event : e
      if(evtobj.ctrlKey) {
        switch(evtobj.keyCode) {
          case 49:
            alert(1)
          break;
          case 50:
          alert(2)
          break;
          case 51:
          alert(3)
          break;
        }
      }
        if (evtobj.keyCode == 90 && evtobj.ctrlKey) alert("Ctrl+z");
      }
    }
  }
</script>