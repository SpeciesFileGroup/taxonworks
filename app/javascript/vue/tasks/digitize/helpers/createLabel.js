export default function(label) {
  let tab = window.open('')
  tab.document.write(`
  <html>
    <body>
      <div><p>${label}</p></div>
    </body>
  </html>`)
}