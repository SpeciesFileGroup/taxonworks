class testClass {
  constructor(message) {
    this._message = message;
  }
 
  get message() {
    return this._message;
  }
 
}
 
var testingE6 = new testClass('Yay!! ES6 Working!! :D');
console.log(testingE6.message);