import L from 'leaflet'

import blueIcon from './img/marker-icon-2x-blue.png'
import goldIcon from './img/marker-icon-2x-gold.png'
import redIcon from './img/marker-icon-2x-red.png'
import greenIcon from './img/marker-icon-2x-green.png'
import orangeIcon from './img/marker-icon-2x-orange.png'
import yellowIcon from './img/marker-icon-2x-yellow.png'
import violetIcon from './img/marker-icon-2x-violet.png'
import greyIcon from './img/marker-icon-2x-grey.png'
import blackIcon from './img/marker-icon-2x-black.png'
import shadowImage from './img/marker-shadow.png'

const defaultProperties = {
  shadowUrl: shadowImage,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowSize: [41, 41]
}

const Icon = {
  blue: new L.Icon({
    iconUrl: blueIcon,
    ...defaultProperties
  }),

  gold: new L.Icon({
    iconUrl: goldIcon,
    ...defaultProperties
  }),

  red: new L.Icon({
    iconUrl: redIcon,
    ...defaultProperties
  }),

  green: new L.Icon({
    iconUrl: greenIcon,
    ...defaultProperties
  }),

  orange: new L.Icon({
    iconUrl: orangeIcon,
    ...defaultProperties
  }),

  yellow: new L.Icon({
    iconUrl: yellowIcon,
    ...defaultProperties
  }),

  violet: new L.Icon({
    iconUrl: violetIcon,
    ...defaultProperties
  }),

  grey: new L.Icon({
    iconUrl: greyIcon,
    ...defaultProperties
  }),

  black: new L.Icon({
    iconUrl: blackIcon,
    ...defaultProperties
  })
}

export {
  Icon
}
