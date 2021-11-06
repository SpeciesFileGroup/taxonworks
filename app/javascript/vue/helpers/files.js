function downloadTextFile (text, fileType, fileName) {
  const blob = new Blob([text], { type: fileType })
  const a = document.createElement('a')

  a.download = fileName
  a.href = URL.createObjectURL(blob)
  a.dataset.downloadurl = [fileType, a.download, a.href].join(':')
  a.style.display = 'none'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  setTimeout(() => { URL.revokeObjectURL(a.href) }, 1500)
}

function blobToArrayBuffer (blob) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()

    reader.addEventListener('loadend', (_) => {
      resolve(reader.result)
    })
    reader.addEventListener('error', reject)
    reader.readAsArrayBuffer(blob)
  })
}

export {
  blobToArrayBuffer,
  downloadTextFile
}