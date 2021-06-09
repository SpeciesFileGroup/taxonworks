<template>
  <div
    title="Lock / Unlock">
    <label class="switch-lock">
      <input
        v-model="checked"
        type="checkbox">
      <span>
        <em></em>
        <strong></strong>
      </span>
    </label>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    checked: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>
<style lang="scss">
$primary: #FFDA44;
$lightGrey: #99A3BA;

.switch-lock {
  height: 26px;
  display: block;
  position: relative;
  cursor: pointer;
  input {
    display: none;
    & + span {
      padding-left: 50px;
      min-height: 26px;
      line-height: 26px;
      display: block;
      color: $lightGrey;
      position: relative;
      vertical-align: middle;
      white-space: nowrap;
      transition: color .3s ease;
      &:before,
      &:after {
        content: '';
        display: block;
        position: absolute;
        border-radius: 12px;
      }
      &:before {
        top: 0;
        left: 0;
        width: 48px;
        height: 28px;
        background: #E4ECFA;
        transition: all .3s ease;
      }
      &:after {
        width: 24px;
        height: 24px;
        background: #fff;
        top: 2px;
        left: 3px;
        box-shadow: 0 1px 3px rgba(#121621, .1);
        transition: all .45s ease;
      }
      em {
        width: 8px;
        height: 7px;
        background: $lightGrey;
        position: absolute;
        left: 11px;
        bottom: 7px;
        border-radius: 2px;
        display: block;
        z-index: 1;
        transition: all .45s ease;
        &:before {
          content: '';
          width: 2px;
          height: 2px;
          border-radius: 1px;
          background: #fff;
          position: absolute;
          display: block;
          left: 50%;
          top: 50%;
          margin: -1px 0 0 -1px;
        }
        &:after {
          content: '';
          display: block;
          border-top-left-radius: 4px;
          border-top-right-radius: 4px;
          border: 1px solid $lightGrey;
          border-bottom: 0;
          width: 6px;
          height: 4px;
          left: 1px;
          bottom: 6px;
          position: absolute;
          z-index: 1;
          transform-origin: 0 100%;
          transition: all .45s ease;
          transform: rotate(-35deg) translate(0, 1px);
        }
      }
      strong {
        font-weight: normal;
        position: relative;
        display: block;
        top: 1px;
        &:before,
        &:after {
          font-size: 14px;
          font-weight: 500;
          display: block;
          font-family: Arial;
          -webkit-backface-visibility: hidden;
        }
        &:before {
          content: '';
          transition: all .3s ease .2s;
        }
        &:after {
          content: '';
          opacity: 0;
          visibility: hidden;
          position: absolute;
          left: 0;
          top: 0;
          color: $primary;
          transition: all .3s ease;
          transform: translate(2px, 0);
        }
      }
    }
    &:checked {
      & + span {
        &:before {
          background: rgba($primary, 1);
        }
        &:after {
          background: #fff;
          transform: translate(18px, 0);
        }
        em {
          transform: translate(18px, 0);
          &:after {
            transform: rotate(0deg) translate(-1px, 0);
          }
        }
        strong {
          &:before {
            opacity: 0;
            visibility: hidden;
            transition: all .3s ease;
            transform: translate(-2px, 0);
          }
          &:after {
            opacity: 1;
            visibility: visible;
            transform: translate(0, 0);
            transition: all .3s ease .2s;
          }
        }
      }
    }
  }
}
</style>
