<template>
  <svg
    class="super-autocomplete-spinner"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 100 100"
    preserveAspectRatio="xMidYMid"
    style="shape-rendering: auto; display: block"
  >
    <g>
      <g transform="matrix(1,0,0,1,26.66666603088379,26.66666603088379)">
        <rect
          fill="#305fc4"
          height="40"
          width="40"
          y="-20"
          x="-20"
          transform="matrix(1.1200006008148193,0,0,1.075000524520874,0,0)"
        ></rect>
      </g>
      <g transform="matrix(1,0,0,1,73.33333587646484,26.66666603088379)">
        <rect
          fill="#ecdc59"
          height="40"
          width="40"
          y="-20"
          x="-20"
          transform="matrix(1.0900006294250488,0,0,1.0900006294250488,0,0)"
        ></rect>
      </g>
      <g transform="matrix(1,0,0,1,26.66666603088379,73.33333587646484)">
        <rect
          fill="#db3f3f"
          height="40"
          width="40"
          y="-20"
          x="-20"
          transform="matrix(1.1200006008148193,0,0,1.1200006008148193,0,0)"
        ></rect>
      </g>
      <g transform="matrix(1,0,0,1,73.33333587646484,73.33333587646484)">
        <rect
          fill="#53c652"
          height="40"
          width="40"
          y="-20"
          x="-20"
          transform="matrix(1.105000615119934,0,0,1.105000615119934,0,0)"
        ></rect>
      </g>
    </g>
  </svg>
</template>

<style scoped>
.super-autocomplete-spinner {
  position: absolute;
  top: 6px;
  right: 8px;
  width: 16px;
  height: 16px;
}

.super-autocomplete-spinner rect {
  transform-origin: center;
  animation: pulse 1.2s infinite ease-in-out;
}

.super-autocomplete-spinner g:nth-child(1) rect {
  animation-delay: 0s;
}

.super-autocomplete-spinner g:nth-child(2) rect {
  animation-delay: 0.2s;
}

.super-autocomplete-spinner g:nth-child(3) rect {
  animation-delay: 0.4s;
}

.super-autocomplete-spinner g:nth-child(4) rect {
  animation-delay: 0.6s;
}

@keyframes pulse {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(0.8);
  }
}
</style>
