const truncateDecimal = (number, truncate) => {
  return parseFloat(new Intl.NumberFormat('en-IN', { maximumFractionDigits: truncate }).format(parseFloat(number)))
}

export {
  truncateDecimal
}
