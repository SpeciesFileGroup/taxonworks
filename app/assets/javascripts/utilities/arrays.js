//Split arrays in groups

(function() {
    Array.prototype.chunk = function (chunkSize) {
        var n = this.length;

        if (chunkSize >= n) {
            return [this];
        }

        if (n == 0) {
            return [];
        }

        var r = n % chunkSize;
        var q = (n - r) / chunkSize;
        var result = [];

        for (var i = 0; i <= q; i++) {
            result.push(this.slice(i * chunkSize, i * chunkSize + chunkSize));
        }

        return result;
    };
})();